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

# Folder Path
ROOT_DIR=`pwd`
PATCH_DIR=$ROOT_DIR/patch_file
TEMPDIR=$ROOT_DIR/tmp_install

CPU_CORE=32

# source download from -https://github.com/systemd/systemd/releases/tag/v244
# Build for systemd library
SYSTEMD_PACKAGE="systemd-244"
MESON_PACKAGE="meson-master"

# source download from -http://www.linuxfromscratch.org/blfs/view/cvs/general/dbus.html
# dependency with systemd
DBUS_PACKAGE="dbus-1.13.18"

function preprocess()
{
    cd $ROOT_DIR
    echo -e "######## \e[01;33m cleaning and unzipping $SYSTEMD_PACKAGE \e[00m ########"
    rm -rf $SYSTEMD_PACKAGE
    tar zxf $SYSTEMD_PACKAGE.tar.gz

}

function generate_cross_file()
{
    echo -e "######## \e[01;33m Setup Cross Compiling file with Meson for systemd\e[00m ########"
    cd $ROOT_DIR
    rm -rf cross_file.txt

    echo "Generate Setup Cross Compiling file."
    if [ "$BIT" = "32" ]; then
        echo "32bit ARM arm-linux-gnueabihf"
        python3.6 setup_cross_file.py "arm-linux-gnueabihf"
    elif [ "$BIT" = "64" ]; then
        echo "64bit ARM aarch64-linux-gnu"
        python3.6 setup_cross_file.py "aarch64-linux-gnu"
    fi
}

function patch_systemd()
{
    cd $ROOT_DIR
    # error: result of ¡¥1 << 31¡¦ requires 33 bits to represent
    # Temp solution : G_PARAM_DEPRECATED          =  __UINT32_C(1) << 31
    cp $PATCH_DIR/glib_patch/gparam.h $ROOT_DIR/glib-2.40.2/install/include/glib-2.0/gobject/gparam.h

}


function build_systemd_meson()
{
        export PKG_CONFIG_PATH=$ROOT_DIR/tmp_install/lib/pkgconfig
        export PATH=$ROOT_DIR/Env/bin/:$PATH
        export PATH=$ROOT_DIR/ninja-1.9.0/:$PATH

        cd $ROOT_DIR/$SYSTEMD_PACKAGE

        # remove the build directory
        rm -rf build

        python3.6 $ROOT_DIR/$MESON_PACKAGE/meson.py build \
                -Dgcrypt=false \
                -Defi=false \
                -Dnetworkd=false \
                -Dblkid=false \
                -Ddbus=false \
                -Dglib=false \
                -Dkmod=false \
                -Dlibcurl=false \
                -Dlz4=false \
                -Dxz=false \
                -Dsysusers=false \
                -Dfirstboot=false \
                -Dsplit-usr=true \
                -Dlibidn=false \
                -Dselinux=true \
                -Drootlibdir="/lib" \
                -Drootprefix="/usr" \
                --cross-file ../cross_file.txt
}

#                -Dnss-myhostname=false


function build_systemd_ninja()
{
        export PKG_CONFIG_PATH=$ROOT_DIR/tmp_install/lib/pkgconfig
        export PATH=$ROOT_DIR/Env/bin/:$PATH
        export PATH=$ROOT_DIR/ninja-1.9.0/:$PATH

        rm -rf install
        mkdir -p install

        cd $ROOT_DIR/$SYSTEMD_PACKAGE

        while [ ! -d $ROOT_DIR/$SYSTEMD_PACKAGE/build ]
        do
                sleep 0.5
        done

        cd build

        ninja
        DESTDIR=$ROOT_DIR/$SYSTEMD_PACKAGE/install ninja install
        cp -rf $ROOT_DIR/$SYSTEMD_PACKAGE/install/* $TEMPDIR/
        #Copy Synamedia required header file
        cp -f $ROOT_DIR/$SYSTEMD_PACKAGE/src/systemd/*.h $TEMPDIR/include/
        tar zcvf $BUILDSYS_DIR/../../lib/platform_libs/systemd-244/${SYSTEMD_PACKAGE}_${BIT}_lib.tar.gz -C $ROOT_DIR/$SYSTEMD_PACKAGE/install/lib ./
}




generate_cross_file
patch_systemd
build_systemd_meson
build_systemd_ninja

