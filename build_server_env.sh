#!/bin/sh

CFLAGS_SETTING="-fPIC"
CPPFLAGS_SETTING="-fPIC"
LDFLAGS_SETTING=""
BUILD="x86_64-linux-gnu"

# source download from -https://github.com/mesonbuild/meson
# Build for menson library 20191220
#MENSON_PACKAGE="meson-0.52.1"
MENSON_PACKAGE="meson-master"

# source download from -https://github.com/ninja-build/ninja/releases
# Build for ninja library
NINJA_PACKAGE="ninja-1.9.0"

# source download from -https://github.com/skvadrik/re2c/releases
# Build for re2c library
RE2C_PACKAGE="re2c-1.3"

# source download from -http://ftp.gnu.org/gnu/glibc/
# Build for glibc library
GLIBC_PACKAGE="glibc-2.25"

ROOT_DIR=`pwd`
BUILD_ENV=$ROOT_DIR/Env
PRJ_DIR=${BUILD_PLATFORM_PATH}/

function toolchain_setting()
{
    cd ${TOOLCHAIN}
    echo `pwd`
    if [ ! -e "${PRJ_DIR}/../../bin/toolchain/arm_eabi-2011.03/bin" ] ; then
        cd ${PRJ_DIR}/../../bin/toolchain
        tar -xzf ${PRJ_DIR}/../../bin/toolchain/arm_eabi-2011.03.tar.gz
    fi
    PATH_LDR_32bits=${PRJ_DIR}/../../bin/toolchain/arm_eabi-2011.03/bin/
    if [ ! -e "${PRJ_DIR}/../../bin/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf/bin" ] ; then
        cd ${PRJ_DIR}/../../bin/toolchain
        tar -xzf ${PRJ_DIR}/../../bin/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf.tar.gz
    fi
    PATH_USER_32bits=${PRJ_DIR}/../../bin/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf/bin/
    if [ ! -e "${PRJ_DIR}/../../bin/toolchain/linaro_aarch64_linux-2014.09_r20170413/bin" ] ; then
        cd ${PRJ_DIR}/../../bin/toolchain
        tar -xzf ${PRJ_DIR}/../../bin/toolchain/linaro_aarch64_linux-2014.09_r20170413.tar.gz
    fi
    PATH_USER_64bits=${PRJ_DIR}/../../bin/toolchain/linaro_aarch64_linux-2014.09_r20170413/bin/
    if [ ! -e "${PRJ_DIR}/../../bin/toolchain/linaro_aarch64_linux-2014.09_r20170413/bin" ] ; then
        cd ${PRJ_DIR}/../../bin/toolchain
        tar -xzf ${PRJ_DIR}/../../bin/toolchain/linaro_aarch64_linux-2014.09_r20170413.tar.gz
    fi
    PATH_KERNEL_64bits=${PRJ_DIR}/../../bin/toolchain/linaro_aarch64_linux-2014.09_r20170413/bin/
}

function preprocess()
{
    cd $ROOT_DIR

    rm -rf $BUILD_ENV
    mkdir -p $BUILD_ENV

    echo -e "######## \e[01;33m cleaning and unzipping $RE2C_PACKAGE \e[00m ########"
    rm -rf $RE2C_PACKAGE
    tar zxf $RE2C_PACKAGE.tar.gz

    echo -e "######## \e[01;33m cleaning and unzipping $NINJA_PACKAGE \e[00m ########"
    rm -rf $NINJA_PACKAGE
    tar zxf $NINJA_PACKAGE.tar.gz

    #meson-master
    echo -e "######## \e[01;33m cleaning and unzipping $MENSON_PACKAGE \e[00m ########"
    rm -rf $MENSON_PACKAGE
    unzip $MENSON_PACKAGE.zip

}

function build_re2c()
{
    cd $ROOT_DIR/$RE2C_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $RE2C_PACKAGE \e[00m ########"
    ./autogen.sh
    ./configure -q \
                CC="gcc" \
                CXX="g++" \
                CPPFLAGS="$CPPFLAGS_SETTING" \
                CFLAGS="$CFLAGS_SETTING" \
                LDFLAGS="$LDFLAGS_SETTING" \
                --prefix="$ROOT_DIR/$RE2C_PACKAGE/install" || exit 1
    make clean || exit 1
    make --quiet CC=gcc -j$CPU_CORE || exit 1
    make install || exit 1
    cp -rf $ROOT_DIR/$RE2C_PACKAGE/install/bin $BUILD_ENV/
}


function build_ninja()
{

    echo -e "######## \e[01;33m building $NINJA_PACKAGE \e[00m ########"
    cd $ROOT_DIR/$NINJA_PACKAGE

    export PATH=$PATH:$BUILD_ENV/bin
    python3 ./configure.py --bootstrap --host="linux"\
    || exit 1

    echo -e "######## \e[01;33m End building $NINJA_PACKAGE \e[00m ########"
}

pushd ./
toolchain_setting
preprocess
build_re2c
build_ninja
popd

echo -e "######## \e[01;33m Finish setting-up env (toolchain, MENSON, NINJA) \e[00m ########"
