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


# source download from -http://www.linuxfromscratch.org/blfs/view/cvs/general/dbus.html
# dependency with systemd
DBUS_PACKAGE="dbus-1.13.18"


TEMPDIR=$ROOT_DIR/tmp_install
PREBUILD_DIR=$ROOT_DIR/install

function build_dbus_withsystemd()
{
    cd $ROOT_DIR/$DBUS_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $DBUS_PACKAGE with systemd\e[00m ########"

    ./configure -q \
            CPPFLAGS="$CPPFLAGS_SETTING -I$TEMPDIR/include -I$TEMPDIR/usr/include" \
            CFLAGS="$CFLAGS_SETTING -I$TEMPDIR/include -I$TEMPDIR/include" \
            LDFLAGS="$LDFLAGS_SETTING -L$TEMPDIR/lib -L$TOOLCHAIN_LIBC_LIB -L$TOOLCHAIN_LIBC_USR_LIB  -Wl,--rpath-link -Wl,$TEMPDIR/lib -lpthread -lrt -ldl -lresolv" \
            SYSTEMD_CFLAGS="-I$TEMPDIR/usr/include -L$TOOLCHAIN_LIBC_LIB -L$TOOLCHAIN_LIBC_USR_LIB" \
            SYSTEMD_LIBS="-lsystemd -lrt -ldl" \
            SELINUX_CFLAGS="-L$TEMPDIR/lib -L$TOOLCHAIN_LIBC_LIB -L$TOOLCHAIN_LIBC_USR_LIB  -Wl,--rpath-link -Wl,$TEMPDIR/lib" \
            SELINUX_LIBS="-lsystemd -lrt -ldl -lselinux " \
            PKG_CONFIG="/usr/bin/pkg-config" \
            PKG_CONFIG_PATH="$TEMPDIR/lib/pkgconfig" \
            --host="$HOST" \
            --build="$BUILD" \
            --sysconfdir=/etc \
            --localstatedir=/var \
            --disable-doxygen-docs \
            --disable-xml-docs \
            --enable-systemd \
            --disable-static \
            --exec_prefix="" \
            --enable-selinux || exit 1

    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install DESTDIR=$ROOT_DIR/$DBUS_PACKAGE/install || exit 1
    cp -rf $ROOT_DIR/$DBUS_PACKAGE/install/* $TEMPDIR
    cp -rf $ROOT_DIR/$DBUS_PACKAGE/install/lib/* $TEMPDIR/lib/
    cp -rf $ROOT_DIR/$DBUS_PACKAGE/install/libexec/* $TEMPDIR/usr/local/libexec/
    tar zcvf $BUILDSYS_DIR/../../lib/platform_libs/systemd-244/${DBUS_PACKAGE}_${BIT}_lib.tar.gz -C $ROOT_DIR/$DBUS_PACKAGE/install/lib ./
    echo -e "######## \e[01;33m End building $DBUS_PACKAGE with systemd\e[00m ########\n"
}



build_dbus_withsystemd



