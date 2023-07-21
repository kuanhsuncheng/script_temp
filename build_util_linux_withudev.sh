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


# source download from -https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.34/util-linux-2.34.tar.gz
# dependency with systemd for libmount & blkid
UTIL_LINUX_PACKAGE="util-linux-2.36"

# source download from -https://ftp.gnu.org/pub/gnu/ncurses/
# Build for ncurses library
NCURSES_PACKAGE="ncurses-6.1"

TEMPDIR=$ROOT_DIR/tmp_install
PREBUILD_DIR=$ROOT_DIR/install

function build_util_linux_withudev()
{

    cd $ROOT_DIR/$UTIL_LINUX_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $UTIL_LINUX_PACKAGE \e[00m ########"
    ./configure -q \
                CPPFLAGS="$CPPFLAGS_SETTING -I$TEMPDIR/include" \
                CFLAGS="$CFLAGS_SETTING -I$TEMPDIR/include -I$TEMPDIR/usr/include" \
                LDFLAGS="$LDFLAGS_SETTING -L$TEMPDIR/lib -L$ROOT_DIR/$NCURSES_PACKAGE/install/lib -lpthread -lselinux -lpcre2-8 -ldl -ludev -lrt" \
                LIBS="-lpthread" \
                PKG_CONFIG_PATH="$TEMPDIR/lib/pkgconfig" \
                --disable-bash-completion \
                --disable-makeinstall-chown \
                --without-python \
                --with-selinux \
                --with-udev \
                --host="$HOST" \
                --build="$BUILD" \
                --prefix=$ROOT_DIR/$UTIL_LINUX_PACKAGE/install || exit 1
    sed -i 's/#define HAVE_GETRANDOM 1/#undef HAVE_GETRANDOM/g' ./config.h


    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install || exit 1
    mkdir -p $TEMPDIR/sbin
    cp -rf $ROOT_DIR/$UTIL_LINUX_PACKAGE/install/sbin/sulogin $TEMPDIR/sbin/
    cp -rf $ROOT_DIR/$UTIL_LINUX_PACKAGE/install/sbin/agetty $TEMPDIR/sbin/
    cp -rf $ROOT_DIR/$UTIL_LINUX_PACKAGE/install/lib/* $TEMPDIR/lib/
    cp -rf $ROOT_DIR/$UTIL_LINUX_PACKAGE/install/include/blkid/*.h $TEMPDIR/include/
    cp -rf $ROOT_DIR/$UTIL_LINUX_PACKAGE/install/include/* $TEMPDIR/include/
    cp -rf $ROOT_DIR/$UTIL_LINUX_PACKAGE/install/include/libmount/*.h $TEMPDIR/include/
    tar zcvf $BUILDSYS_DIR/../../lib/platform_libs/systemd-244/${UTIL_LINUX_PACKAGE}_${BIT}_lib.tar.gz -C $ROOT_DIR/$UTIL_LINUX_PACKAGE/install/lib ./
    echo -e "######## \e[01;33m End building $UTIL_LINUX_PACKAGE \e[00m ########"
}


build_util_linux_withudev


