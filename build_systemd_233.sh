#!/bin/sh

if [ $1 = "32" ]; then
    BIT=32
elif [ $1 = "64" ]; then
    BIT=64
fi

BUILDSYS_DIR=${BUILD_PLATFORM_PATH}
if [ "$BIT" = "32" ]; then
    if [ ! -e "$BUILDSYS_DIR/../../bin/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf/bin" ] ; then
        cd $BUILDSYS_DIR/../../bin/toolchain
        tar -xzf $BUILDSYS_DIR/../../bin/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf.tar.gz
    fi
    export PATH=$BUILDSYS_DIR/../../bin/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf/bin/:$PATH
    TOOLCHAIN=${TOOLCHAIN:-"arm-linux-gnueabihf-"}
    HOST="arm-linux-gnueabihf"

elif [ "$BIT" = "64" ]; then
    if [ ! -e "$BUILDSYS_DIR/../../bin/toolchain/linaro_aarch64_linux-2014.09_r20170413/bin" ] ; then
        cd $BUILDSYS_DIR/../../bin/toolchain
        tar -xzf $BUILDSYS_DIR/../../bin/toolchain/linaro_aarch64_linux-2014.09_r20170413.tar.gz
    fi
    export PATH=$BUILDSYS_DIR/../../bin/toolchain/linaro_aarch64_linux-2014.09_r20170413/bin/:$PATH
    TOOLCHAIN=${TOOLCHAIN:-"aarch64-linux-gnu-"}
    HOST="aarch64-linux-gnu"
fi

CFLAGS_SETTING="-fPIC"
CPPFLAGS_SETTING="-fPIC"
LDFLAGS_SETTING=""
BUILD="x86_64-linux-gnu"
export CC="${TOOLCHAIN}gcc"
export CXX="${TOOLCHAIN}g++"
export LD="${TOOLCHAIN}ld -EL"
export AR="${TOOLCHAIN}ar"
export RANLIB="${TOOLCHAIN}ranlib"

ROOT_DIR=`pwd`
CPU_CORE=32

if [ "$BIT" = "32" ]; then
    TOOLCHAIN_LIBC_USR_LIB=`which $CC`/../$HOST/libc/usr/lib
    TOOLCHAIN_LIBC_USR_LIB=`echo $TOOLCHAIN_LIBC_USR_LIB | sed 's/arm-linux-gnueabihf-gcc\///g'`
    TOOLCHAIN_LIBC_LIB=`which $CC`/../$HOST/libc/lib
    TOOLCHAIN_LIBC_LIB=`echo $TOOLCHAIN_LIBC_LIB | sed 's/arm-linux-gnueabihf-gcc\///g'`
elif [ "$BIT" = "64" ]; then
    TOOLCHAIN_LIBC_USR_LIB=`which $CC`/../$HOST/libc/usr/lib/$HOST
    TOOLCHAIN_LIBC_USR_LIB=`echo $TOOLCHAIN_LIBC_USR_LIB | sed 's/aarch64-linux-gnu-gcc\///g'`
    TOOLCHAIN_LIBC_LIB=`which $CC`/../$HOST/libc/lib/$HOST
    TOOLCHAIN_LIBC_LIB=`echo $TOOLCHAIN_LIBC_LIB | sed 's/aarch64-linux-gnu-gcc\///g'`
fi


TEMPDIR=$ROOT_DIR/tmp_install
PREBUILD_DIR=$ROOT_DIR/install

# source download from -https://github.com/systemd/systemd/releases/tag/v233
# patch https://github.com/karelzak/systemd/commit/eb50b6d936c474f5bc2974c059f6432222af4de4
SYSTEMD_PACKAGE="systemd-233"

function build_systemd()
{
 
    cd $ROOT_DIR/$SYSTEMD_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $SYSTEMD_PACKAGE \e[00m ########"
    ./configure -q \
                CPPFLAGS="$CPPFLAGS_SETTING -I$TEMPDIR/includee" \
                CFLAGS="$CFLAGS_SETTING -I$TEMPDIR/include" \
                LDFLAGS="$LDFLAGS_SETTING -L$TEMPDIR/lib  -L$TEMPDIR/libexec/sudo -Wl,--rpath-link -Wl,$TEMPDIR/lib" \
                LIBS="-lcap -lmount -lgcrypt -lgpg-error -lblkid -lkmod -llz4 -lrt -lm -lz -lpthread" \
                MOUNT_CFLAGS="-Os" \
                MOUNT_LIBS="-lmount" \
                MOUNT_PATH="/bin/mount" \
                KMOD_CFLAGS="" \
                KMOD_LIBS="-lkmod" \
                KMOD="/bin/kmod" \
                PKG_CONFIG_PATH="$TEMPDIR/lib/pkgconfig" \
                --without-python \
                --sysconfdir=/etc \
                --localstatedir=/var \
                --libdir=/lib \
                --host="$HOST" \
                --build="$BUILD" \
                --disable-manpages \
                --disable-selinux \
                --disable-libidn \
                --enable-lz4 \
                --disable-xz \
                --enable-split-usr \
                --config-cache \
                --enable-kmod \
                --disable-sysusers \
                --disable-firstboot
    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install DESTDIR=$ROOT_DIR/$SYSTEMD_PACKAGE/install || exit 1
    cp -rf $ROOT_DIR/$SYSTEMD_PACKAGE/install/* $TEMPDIR/
    #Copy Synamedia required header file
    cp -f $ROOT_DIR/$SYSTEMD_PACKAGE/src/systemd/*.h $TEMPDIR/include/
    echo -e "######## \e[01;33m End building $SYSTEMD_PACKAGE \e[00m ########\n"
}


build_systemd



