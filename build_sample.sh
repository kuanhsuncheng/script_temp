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
export STRIP="${TOOLCHAIN}strip"


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

# source download from -https://XXXXXXXXX
# Build for XXXXX library
XXX_PACKAGE="1.2.3"



TEMPDIR=$ROOT_DIR/tmp_install
PREBUILD_DIR=$ROOT_DIR/install

function preprocess()
{

    echo -e "######## \e[01;33m cleaning and unzipping $XXX_PACKAGE \e[00m ########"
    rm -rf $XXX_PACKAGE
    tar zxf $XXX_PACKAGE.tar.gz

}


function build_XXX()
{
    cd $ROOT_DIR/$XXX_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $XXX_PACKAGE \e[00m ########"
    ./configure -q \
                CPPFLAGS="$CPPFLAGS_SETTING" \
                CFLAGS="$CFLAGS_SETTING" \
                LDFLAGS="$LDFLAGS_SETTING " \
                --host="$HOST" \
                --build="$BUILD" \
                --prefix=$ROOT_DIR/$XXX_PACKAGE/install || exit 1

    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install || exit 1
    #mkdir -p $TEMPDIR/sbin

    #cp -rf $ROOT_DIR/$XXX_PACKAGE/install/lib/* $TEMPDIR/lib/

    echo -e "######## \e[01;33m End building $XXX_PACKAGE \e[00m ########"
}


preprocess

build_XXX