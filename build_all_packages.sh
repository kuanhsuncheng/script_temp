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

CFLAGS_SETTING="-fPIC -Os"
CPPFLAGS_SETTING="-fPIC -Os"
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
# source download from hqtvrd/sn_oss/busybox
# commit 4cc8267531c766fa4ced914eee1c00703d0935b4
# use configs/.config.arm.supportLess
BUSYBOX_PACKAGE="busybox-1.22.1"

# source download from - https://www.sudo.ws/
SUDO_PACKAGE="sudo-1.8.28b3"

# source download from - https://zlib.net/
# dependency with glib
ZLIB_PACKAGE="zlib-1.2.11"

# source download from - https://sourceware.org/libffi/
# dependency with glib
LIBFFI_PACKAGE="libffi-3.2.1"

# source download from -https://ftp.gnome.org/pub/gnome/sources/glib/
# dependency with dbus
# patch https://github.com/widora/openwrt_widora/issues/12
GLIB_PACKAGE="glib-2.40.2"

# source download from -https://github.com/libexpat/libexpat/releases
# dependency with dbus
EXPAT_PACKAGE="expat-2.2.7"

# source download from -http://www.linuxfromscratch.org/blfs/view/cvs/general/dbus.html
# dependency with systemd
DBUS_PACKAGE="dbus-1.12.16"

# source download from -http://www.linuxfromscratch.org/blfs/view/systemd/general/libgpg-error.html
# dependency with gcrypt
GPG_ERROR_PACKAGE="libgpg-error-1.36"

# source download from -http://www.linuxfromscratch.org/blfs/view/systemd/general/libgcrypt.html
# dependency with systemd
GCRYPT_PACKAGE="libgcrypt-1.8.5"

# source download from -https://git.kernel.org/pub/scm/libs/libcap/libcap.git/snapshot/libcap-2.27.tar.gz
# dependency with systemd
CAP_PACKAGE="libcap-2.27"

# source download from DK
# dependency with util-linux
LIBPYTHON_PACKAGE="libpython2.7_extract"
# source download from -http://ftp.pl.debian.org/debian/pool/main/p/python2.7/
# dpkg -x libpython2.7-dbg_2.7.9-2+deb8u1_armhf.deb libpython2.7-dev_2.7.9-2_armhf_extracted
# dependency with util-linux
PYTHON_PACKAGE="libpython2.7-dev_2.7.9-2_armhf_extracted"


# source download from -https://packages.debian.org/stretch/libtinfo-dev
# dependency with util-linux
#if [ "$BIT" = "32" ]; then
#    TINFO_PACKAGE_NAME="libtinfo-dev_6.0+20161126-1+deb9u2_armhf.deb"
#elif [ "$BIT" = "64" ]; then
#    TINFO_PACKAGE_NAME="libtinfo-dev_6.0+20161126-1+deb9u2_arm64.deb"
#fi
#TINFO_PACKAGE="libtinfo_extracted"

# source download from -https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.34/util-linux-2.34.tar.gz
# dependency with systemd for libmount & blkid
UTIL_LINUX_PACKAGE="util-linux-2.34"

# source download from -https://github.com/systemd/systemd/releases/tag/v233
# patch https://github.com/karelzak/systemd/commit/eb50b6d936c474f5bc2974c059f6432222af4de4
SYSTEMD_PACKAGE="systemd-233"

# source download from -https://mirrors.edge.kernel.org/pub/linux/utils/kernel/kmod/
KMOD_PACKAGE="kmod-26"

# source download from -https://curl.haxx.se/download.html
CURL_PACKAGE="curl-7.65.3"

# source download from -https://tukaani.org/xz/
# Build for lzma library
XZ_PACKAGE="xz-5.2.4"

# source download from -https://github.com/lz4/lz4/releases/tag/v1.9.2
# Build for lz4 library
LZ4_PACKAGE="lz4-1.9.2"

# source download from -https://ftp.gnu.org/pub/gnu/ncurses/
# Build for ncurses library
NCURSES_PACKAGE="ncurses-6.1"



TEMPDIR=$ROOT_DIR/tmp_install
PREBUILD_DIR=$ROOT_DIR/install
function preprocess()
{
    rm -rf $TEMPDIR
    mkdir -p $TEMPDIR
    mkdir -p $TEMPDIR/lib
    mkdir -p $TEMPDIR/lib64
    mkdir -p $TEMPDIR/include
    mkdir -p $TEMPDIR/bin
    mkdir -p $TEMPDIR/usr/local

    if [ "$BIT" = "32" ]; then
        rm -rf $PREBUILD_DIR
    fi
    mkdir -p $PREBUILD_DIR
    mkdir -p $PREBUILD_DIR/lib64
    mkdir -p $PREBUILD_DIR/header

    echo -e "######## \e[01;33m cleaning and unzipping $SUDO_PACKAGE \e[00m ########"
    rm -rf $SUDO_PACKAGE
    tar zxf $SUDO_PACKAGE.tar.gz

    echo -e "######## \e[01;33m cleaning and unzipping $ZLIB_PACKAGE \e[00m ########"
    rm -rf $ZLIB_PACKAGE
    tar zxf $ZLIB_PACKAGE.tar.gz

    echo -e "######## \e[01;33m cleaning and unzipping $LIBFFI_PACKAGE \e[00m ########"
    rm -rf $LIBFFI_PACKAGE
    tar zxf $LIBFFI_PACKAGE.tar.gz

    echo -e "######## \e[01;33m cleaning and unzipping $GLIB_PACKAGE \e[00m ########"
    rm -rf $GLIB_PACKAGE
    tar Jxf $GLIB_PACKAGE.tar.xz

    echo -e "######## \e[01;33m cleaning and unzipping $EXPAT_PACKAGE \e[00m ########"
    rm -rf $EXPAT_PACKAGE
    tar zxf $EXPAT_PACKAGE.tar.gz

    echo -e "######## \e[01;33m cleaning and unzipping $DBUS_PACKAGE \e[00m ########"
    rm -rf $DBUS_PACKAGE
    tar zxf $DBUS_PACKAGE.tar.gz

    echo -e "######## \e[01;33m cleaning and unzipping $GCRYPT_PACKAGE \e[00m ########"
    rm -rf $GCRYPT_PACKAGE
    tar zxf $GCRYPT_PACKAGE.tar.gz

    echo -e "######## \e[01;33m cleaning and unzipping $GPG_ERROR_PACKAGE \e[00m ########"
    rm -rf $GPG_ERROR_PACKAGE
    tar jxf $GPG_ERROR_PACKAGE.tar.bz2

    echo -e "######## \e[01;33m cleaning and unzipping $KMOD_PACKAGE \e[00m ########"
    rm -rf $KMOD_PACKAGE
    tar Jxf $KMOD_PACKAGE.tar.xz

    echo -e "######## \e[01;33m cleaning and unzipping $CURL_PACKAGE \e[00m ########"
    rm -rf $CURL_PACKAGE
    tar jxf $CURL_PACKAGE.tar.bz2

    echo -e "######## \e[01;33m cleaning and unzipping $CAP_PACKAGE \e[00m ########"
    rm -rf $CAP_PACKAGE
    tar zxf $CAP_PACKAGE.tar.gz

    echo -e "######## \e[01;33m cleaning and unzipping $UTIL_LINUX_PACKAGE \e[00m ########"
    rm -rf $UTIL_LINUX_PACKAGE
    tar zxf $UTIL_LINUX_PACKAGE.tar.gz

    #echo -e "######## \e[01;33m cleaning and unzipping $SYSTEMD_PACKAGE \e[00m ########"
    #rm -rf $SYSTEMD_PACKAGE
    #tar zxf $SYSTEMD_PACKAGE.tar.gz

    echo -e "######## \e[01;33m cleaning and unzipping $LZ4_PACKAGE \e[00m ########"
    rm -rf $LZ4_PACKAGE
    tar zxf $LZ4_PACKAGE.tar.gz

    echo -e "######## \e[01;33m cleaning and unzipping $NCURSES_PACKAGE \e[00m ########"
    rm -rf $NCURSES_PACKAGE
    tar zxf $NCURSES_PACKAGE.tar.gz

}


function build_ncurses()
{
    cd $ROOT_DIR/$NCURSES_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $NCURSES_PACKAGE \e[00m ########"
    ./configure -q \
                CPPFLAGS="$CPPFLAGS_SETTING" \
                CFLAGS="$CFLAGS_SETTING" \
                LDFLAGS="$LDFLAGS_SETTING -lpthread " \
                LIBS="-lpthread" \
                --host="$HOST" \
                --build="$BUILD" \
                --disable-stripping \
                --with-shared \
                --with-termlib=tinfo \
                --with-ticlib=tic \
                --prefix=$ROOT_DIR/$NCURSES_PACKAGE/install || exit 1

    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install || exit 1
    #mkdir -p $TEMPDIR/sbin

    #cp -rf $ROOT_DIR/$NCURSES_PACKAGE/install/lib/* $TEMPDIR/lib/
    #cp -rf $ROOT_DIR/$NCURSES_PACKAGE/install/include/blkid/*.h $TEMPDIR/include/

    echo -e "######## \e[01;33m End building $NCURSES_PACKAGE \e[00m ########"
}

function build_xz()
{
    cd $ROOT_DIR
    if [ "$BIT" = "32" ]; then
        echo -e "######## \e[01;33m cleaning and unzipping $XZ_PACKAGE \e[00m ########"
        rm -rf $XZ_PACKAGE
        tar zxf $XZ_PACKAGE.tar.gz
        echo -e "######## \e[01;33m building $XZ_PACKAGE \e[00m ########"
        mkdir -p $ROOT_DIR/$XZ_PACKAGE/install
        cd $ROOT_DIR/$XZ_PACKAGE
        ./configure -q \
                    CPPFLAGS="$CPPFLAGS_SETTING" \
                    CFLAGS="$CFLAGS_SETTING" \
                    LDFLAGS="$LDFLAGS_SETTING" \
                    --host="$HOST" \
                    --build="$BUILD" \
                    --prefix="$ROOT_DIR/$XZ_PACKAGE/install" || exit 1

        make --quiet clean || exit 1
        make --quiet -j$CPU_CORE || exit 1
        make --quiet install || exit 1
        cp -rf $ROOT_DIR/$XZ_PACKAGE/install/include/*.h $TEMPDIR/include/
        cp -rf $ROOT_DIR/$XZ_PACKAGE/install/bin/* $TEMPDIR/bin/
        cp -rf $ROOT_DIR/$XZ_PACKAGE/install/lib/* $TEMPDIR/lib/
        echo -e "######## \e[01;33m End building $XZ_PACKAGE \e[00m ########"
    elif [ "$BIT" = "64" ]; then
        echo -e "######## \e[01;33m cleaning and unzipping $XZ_PACKAGE \e[00m ########"
        rm -rf $XZ_PACKAGE
        tar zxf $XZ_PACKAGE.tar.gz
        echo -e "######## \e[01;33m building $XZ_PACKAGE \e[00m ########"
        mkdir -p $ROOT_DIR/$XZ_PACKAGE/install
        cd $ROOT_DIR/$XZ_PACKAGE
        ./configure -q \
                    CPPFLAGS="$CPPFLAGS_SETTING" \
                    CFLAGS="$CFLAGS_SETTING" \
                    LDFLAGS="$LDFLAGS_SETTING" \
                    --host="$HOST" \
                    --build="$BUILD" \
                    --prefix="$ROOT_DIR/$XZ_PACKAGE/install" || exit 1

        make --quiet clean || exit 1
        make --quiet -j$CPU_CORE || exit 1
        make --quiet install || exit 1

        cp -rf $ROOT_DIR/$XZ_PACKAGE/install/lib/* $TEMPDIR/lib/
        echo -e "######## \e[01;33m End building $XZ_PACKAGE \e[00m ########"
    fi
}
function build_busybox()
{
    rm -rf $BUSYBOX_PACKAGE
    tar zxf $BUSYBOX_PACKAGE.tar.gz

    cd $ROOT_DIR/busybox/1.22.1/
    chmod 777 -R ./*
    cp -f configs/.config.arm.supportLess .config
    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    # cp busybox binary file to patch file
    cp -f busybox $ROOT_DIR/patch_file/

}
function build_zlib()
{
    cd $ROOT_DIR/$ZLIB_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $ZLIB_PACKAGE \e[00m ########"
    ./configure --prefix="$ROOT_DIR/$ZLIB_PACKAGE/install" || exit 1
    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install || exit 1
    cp -rf $ROOT_DIR/$ZLIB_PACKAGE/install/lib/* $TEMPDIR/lib/
    cp -rf $ROOT_DIR/$ZLIB_PACKAGE/install/include/* $TEMPDIR/include/
    echo -e "######## \e[01;33m End building $ZLIB_PACKAGE \e[00m ########\n"
}
function build_ffi()
{
    cd $ROOT_DIR/$LIBFFI_PACKAGE
    mkdir -p install
    mkdir -p install/lib
    mkdir -p install/include
    echo -e "######## \e[01;33m building $LIBFFI_PACKAGE \e[00m ########"
    ./configure -q \
                CPPFLAGS="$CPPFLAGS_SETTING" \
                CFLAGS="$CFLAGS_SETTING" \
                LDFLAGS="$LDFLAGS_SETTING" \
                --host="$HOST" \
                --build="$BUILD" \
                --prefix="$ROOT_DIR/$LIBFFI_PACKAGE/install" || exit 1
    make clean || exit 1
    make -j$CPU_CORE || exit 1
    make install || exit 1
    mkdir -p install/lib/libffi-3.2.1/include
    if [ "$BIT" = "32" ]; then
        cp -rf $ROOT_DIR/$LIBFFI_PACKAGE/arm-unknown-linux-gnueabihf/.libs/* $TEMPDIR/lib/
        cp -f $ROOT_DIR/$LIBFFI_PACKAGE/arm-unknown-linux-gnueabihf/include/*.h $TEMPDIR/include/
        cp -rf $ROOT_DIR/$LIBFFI_PACKAGE/arm-unknown-linux-gnueabihf/.libs/* $ROOT_DIR/$LIBFFI_PACKAGE/install/lib/
        cp -rf $ROOT_DIR/$LIBFFI_PACKAGE/arm-unknown-linux-gnueabihf/include/*.h  $ROOT_DIR/$LIBFFI_PACKAGE/install/lib/libffi-3.2.1/include/
        cp -rf $ROOT_DIR/$LIBFFI_PACKAGE/arm-unknown-linux-gnueabihf/libffi.pc $TEMPDIR/lib/pkgconfig
        cp -rf $ROOT_DIR/$LIBFFI_PACKAGE/arm-unknown-linux-gnueabihf/libffi.pc $ROOT_DIR/$LIBFFI_PACKAGE/install
    elif [ "$BIT" = "64" ]; then
        cp -rf $ROOT_DIR/$LIBFFI_PACKAGE/aarch64-unknown-linux-gnu/.libs/* $TEMPDIR/lib/
        cp -f $ROOT_DIR/$LIBFFI_PACKAGE/aarch64-unknown-linux-gnu/include/*.h $TEMPDIR/include/
        cp -rf $ROOT_DIR/$LIBFFI_PACKAGE/aarch64-unknown-linux-gnu/.libs/* $ROOT_DIR/$LIBFFI_PACKAGE/install/lib/
        cp -rf $ROOT_DIR/$LIBFFI_PACKAGE/aarch64-unknown-linux-gnu/include/*.h  $ROOT_DIR/$LIBFFI_PACKAGE/install/lib/libffi-3.2.1/include/
        cp -rf $ROOT_DIR/$LIBFFI_PACKAGE/aarch64-unknown-linux-gnu/libffi.pc $TEMPDIR/lib/pkgconfig
        cp -rf $ROOT_DIR/$LIBFFI_PACKAGE/aarch64-unknown-linux-gnu/libffi.pc $ROOT_DIR/$LIBFFI_PACKAGE/install
    fi
    echo -e "######## \e[01;33m End building $LIBFFI_PACKAGE \e[00m ########\n"
}
function build_glib()
{
    cd $ROOT_DIR/$GLIB_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $GLIB_PACKAGE \e[00m ########"
    ./configure -q \
                CPPFLAGS="$CPPFLAGS_SETTING -I$TEMPDIR/include" \
                CFLAGS="$CFLAGS_SETTING -I$TEMPDIR/include" \
                LDFLAGS="$LDFLAGS_SETTING -L$TEMPDIR/lib" \
                LIBFFI_CFLAGS="-I$TEMPDIR/include" \
                LIBFFI_LIBS="-L$TEMPDIR/lib" \
                LIBS="-lffi" \
                glib_cv_stack_grows=no \
                glib_cv_uscore=yes \
                ac_cv_func_posix_getpwuid_r=yes \
                ac_cv_func_posix_getgrgid_r=yes \
                --enable-static=yes \
                --host="$HOST" \
                --prefix="$ROOT_DIR/$GLIB_PACKAGE/install" || exit 1
    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install || exit 1
    cp -rf $ROOT_DIR/$GLIB_PACKAGE/install/lib/* $TEMPDIR/lib/
    cp -rf $ROOT_DIR/$GLIB_PACKAGE/install/include/* $TEMPDIR/include/
    echo -e "######## \e[01;33m End building $GLIB_PACKAGE \e[00m ########\n"
}
function build_expat()
{
    cd $ROOT_DIR/$EXPAT_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $EXPAT_PACKAGE \e[00m ########"
    ./configure -q \
                CPPFLAGS="$CPPFLAGS_SETTING -DXML_POOR_ENTROPY" \
                CFLAGS="$CFLAGS_SETTING -DXML_POOR_ENTROPY" \
                LDFLAGS="$LDFLAGS_SETTING" \
                --host="$HOST" \
                --build="$BUILD" \
                --without-docbook \
                --prefix="$ROOT_DIR/$EXPAT_PACKAGE/install" || exit 1
    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install || exit 1
    cp -rf $ROOT_DIR/$EXPAT_PACKAGE/install/lib/* $TEMPDIR/lib/
    cp -rf $ROOT_DIR/$EXPAT_PACKAGE/install/include/*.h $TEMPDIR/include/
    echo -e "######## \e[01;33m End building $EXPAT_PACKAGE \e[00m ########\n"
}
function build_dbus()
{
    cd $ROOT_DIR/$DBUS_PACKAGE
    mkdir -p install

    echo -e "######## \e[01;33m building $DBUS_PACKAGE \e[00m ########"
    ./configure -q \
            CPPFLAGS="$CPPFLAGS_SETTING -I$TEMPDIR/include" \
            CFLAGS="$CFLAGS_SETTING -I$TEMPDIR/include" \
            LDFLAGS="$LDFLAGS_SETTING -L$TEMPDIR/lib" \
            LIBS="-lffi -lz -lexpat -lpthread -ldl -lresolv" \
            PKG_CONFIG_PATH="$TEMPDIR/lib/pkgconfig" \
            --host="$HOST" \
            --build="$BUILD" \
            --localstatedir=/var \
            --disable-doxygen-docs \
            --disable-xml-docs \
            --disable-selinux \
            --disable-systemd \
            --with-system-socket="/run/dbus/system_bus_socket" \
            --prefix="$ROOT_DIR/$DBUS_PACKAGE/install"  \
            --with-system-pid-file="/run/dbus/pid" || exit 1

    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install || exit 1
    cp -rf $ROOT_DIR/$DBUS_PACKAGE/install/* $TEMPDIR
    cp -rf $ROOT_DIR/$DBUS_PACKAGE/install/lib/* $TEMPDIR/lib/
    echo -e "######## \e[01;33m End building $DBUS_PACKAGE \e[00m ########\n"
}
function build_cap()
{

    echo -e "######## \e[01;33m building $CAP_PACKAGE \e[00m ########"
    cd $ROOT_DIR/$CAP_PACKAGE
    mkdir -p install
    make --quiet clean || exit 1
    make --quiet CC=$CC BUILD_CC=gcc BUILD_GPERF=no prefix=$ROOT_DIR/$CAP_PACKAGE/install lib=lib -j$CPU_CORE || exit 1
    make --quiet CC=$CC BUILD_CC=gcc BUILD_GPERF=no RAISE_SETFCAP=no prefix=$ROOT_DIR/$CAP_PACKAGE/install lib=lib install
    cp -rf $ROOT_DIR/$CAP_PACKAGE/install/lib/* $TEMPDIR/lib
    cp -rf $ROOT_DIR/$CAP_PACKAGE/install/include/* $TEMPDIR/include
    echo -e "######## \e[01;33m End building $CAP_PACKAGE \e[00m ########"
}
function build_util_linux()
{

    cd $ROOT_DIR/$UTIL_LINUX_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $UTIL_LINUX_PACKAGE \e[00m ########"
    ./configure -q \
                CPPFLAGS="$CPPFLAGS_SETTING" \
                CFLAGS="$CFLAGS_SETTING" \
                LDFLAGS="$LDFLAGS_SETTING -L$ROOT_DIR/$NCURSES_PACKAGE/install/lib -lpthread" \
                LIBS="-lpthread" \
                --disable-bash-completion \
                --disable-makeinstall-chown \
                --without-python \
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
    echo -e "######## \e[01;33m End building $UTIL_LINUX_PACKAGE \e[00m ########"
}

function build_gpg_error()
{
    cd $ROOT_DIR/$GPG_ERROR_PACKAGE
    mkdir install
    echo -e "######## \e[01;33m building $GPG_ERROR_PACKAGE \e[00m ########"
    if [ "$BIT" = "32" ]; then
        ./configure -q \
                    CPPFLAGS="$CPPFLAGS_SETTING" \
                    CFLAGS="$CFLAGS_SETTING" \
                    LDFLAGS="$LDFLAGS_SETTING" \
                    --host="arm-unknown-linux-gnueabi" \
                    --build="$BUILD"  \
                    --prefix="$ROOT_DIR/$GPG_ERROR_PACKAGE/install" || exit 1

    elif [ "$BIT" = "64" ]; then
        ./configure -q \
                    CPPFLAGS="$CPPFLAGS_SETTING" \
                    CFLAGS="$CFLAGS_SETTING" \
                    LDFLAGS="$LDFLAGS_SETTING" \
                    --host="aarch64-unknown-linux-gnu" \
                    --build="$BUILD"  \
                    --prefix="$ROOT_DIR/$GPG_ERROR_PACKAGE/install" || exit 1
    fi
    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install || exit 1
    cp -rf $ROOT_DIR/$GPG_ERROR_PACKAGE/install/lib/* $TEMPDIR/lib/
    cp -rf $ROOT_DIR/$GPG_ERROR_PACKAGE/install/include/*.h $TEMPDIR/include/
    echo -e "######## \e[01;33m End building $GPG_ERROR_PACKAGE \e[00m ########"
}


function build_gcrypt()
{
    cd $ROOT_DIR/$GCRYPT_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $GCRYPT_PACKAGE \e[00m ########"
    ./configure -q \
                CPPFLAGS="$CPPFLAGS_SETTING" \
                CFLAGS="$CFLAGS_SETTING" \
                LDFLAGS="$LDFLAGS_SETTING -L$ROOT_DIR/$GPG_ERROR_PACKAGE/install/lib" \
                --with-libgpg-error-prefix="$ROOT_DIR/$GPG_ERROR_PACKAGE/install" \
                --host="$HOST" \
                --build="$BUILD"  \
                --prefix="$ROOT_DIR/$GCRYPT_PACKAGE/install" || exit 1
    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install prefix=$ROOT_DIR/$GCRYPT_PACKAGE/install || exit 1
    cp -rf $ROOT_DIR/$GCRYPT_PACKAGE/install/lib/* $TEMPDIR/lib/
    cp -rf $ROOT_DIR/$GCRYPT_PACKAGE/install/include/*.h $TEMPDIR/include/
    echo -e "######## \e[01;33m End building $IPERF_PACKAGE \e[00m ########\n"
}

function build_curl()
{
    cd $ROOT_DIR/$CURL_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $CURL_PACKAGE \e[00m ########"
    ./configure -q \
                CPPFLAGS="$CPPFLAGS_SETTING -I$TEMPDIR/include" \
                CFLAGS="$CFLAGS_SETTING -I$TEMPDIR/include" \
                LDFLAGS="$LDFLAGS_SETTING -L$TEMPDIR/lib" \
                --host="$HOST" \
                --build="$BUILD"  \
                --disable-gtk-doc-html \
                --prefix=$ROOT_DIR/$CURL_PACKAGE/install \
                --disable-manpages || exit 1
    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install || exit 1
    cp -rf $ROOT_DIR/$CURL_PACKAGE/install/bin $TEMPDIR/
    cp -rf $ROOT_DIR/$CURL_PACKAGE/install/include/* $TEMPDIR/include/
    cp -rf $ROOT_DIR/$CURL_PACKAGE/install/lib/* $TEMPDIR/lib/
    echo -e "######## \e[01;33m End building $CURL_PACKAGE \e[00m ########"
}

function build_kmod()
{
    cd $ROOT_DIR/$KMOD_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $KMOD_PACKAGE \e[00m ########"
    ./configure -q \
                CPPFLAGS="$CPPFLAGS_SETTING -I$TEMPDIR/include" \
                CFLAGS="$CFLAGS_SETTING -I$TEMPDIR/include" \
                LDFLAGS="$LDFLAGS_SETTING -L$TEMPDIR/lib" \
                --host="$HOST" \
                --build="$BUILD"  \
                --disable-gtk-doc-html \
                --disable-manpages \
                --with-bashcompletiondir=$ROOT_DIR/$KMOD_PACKAGE/install \
                --prefix=$ROOT_DIR/$KMOD_PACKAGE/install || exit 1
    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install exec_prefix=$ROOT_DIR/$KMOD_PACKAGE/install || exit 1
    cp -rf $ROOT_DIR/$KMOD_PACKAGE/install/bin $TEMPDIR/
    cp -rf $ROOT_DIR/$KMOD_PACKAGE/install/include/*.h $TEMPDIR/include/
    cp -rf $ROOT_DIR/$KMOD_PACKAGE/install/lib/* $TEMPDIR/lib/
    echo -e "######## \e[01;33m End building $KMOD_PACKAGE \e[00m ########"
}

function build_lz4()
{
    echo -e "######## \e[01;33m building $LZ4_PACKAGE \e[00m ########"
    rm -rf $ROOT_DIR/$LZ4_PACKAGE/install
    mkdir -p $ROOT_DIR/$LZ4_PACKAGE/install
    cd $ROOT_DIR/$LZ4_PACKAGE
    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE|| exit 1
    make --quiet install prefix=$ROOT_DIR/$LZ4_PACKAGE/install || exit 1
    cp -rf $ROOT_DIR/$LZ4_PACKAGE/install/bin $TEMPDIR/
    cp -rf $ROOT_DIR/$LZ4_PACKAGE/install/lib/* $TEMPDIR/lib/
    cp -rf $ROOT_DIR/$LZ4_PACKAGE/install/include/*.h $TEMPDIR/include/
    echo -e "######## \e[01;33m End building $LZ4_PACKAGE \e[00m ########"
}


function build_sudo()
{
    cd $ROOT_DIR/$SUDO_PACKAGE
    mkdir -p install
    echo -e "######## \e[01;33m building $SUDO_PACKAGE \e[00m ########"
    ./configure -q \
                CPPFLAGS="$CPPFLAGS_SETTING" \
                CFLAGS="$CFLAGS_SETTING" \
                LDFLAGS="$LDFLAGS_SETTING" \
                --host="$HOST" \
                --build="$BUILD" \
                sudo_cv_gettext=no \
                sudo_cv_gettext_lintl=no \
                sudo_cv_gettext_lintl_liconv=no \
                sudo_cv_func_fnmatch=no \
                sudo_cv_sock_sa_len=no \
                sudo_cv_uid_t_len=10 \
                sudo_cv_type_long_is_quad=no \
                sudo_cv_func_unsetenv_void=no  || exit 1|| exit 1
    make --quiet clean || exit 1
    make --quiet -j$CPU_CORE || exit 1
    make --quiet install DESTDIR=$ROOT_DIR/$SUDO_PACKAGE/install || exit 1
    cp -rf $ROOT_DIR/$SUDO_PACKAGE/install/etc/* $TEMPDIR/etc/
    cp -rf $ROOT_DIR/$SUDO_PACKAGE/install/usr/local/libexec $TEMPDIR/usr/local/
    cp -rf $ROOT_DIR/$SUDO_PACKAGE/install/usr/local/bin $TEMPDIR/usr/local/
    cp -rf $ROOT_DIR/$SUDO_PACKAGE/install/usr/local/sbin $TEMPDIR/usr/local/
    echo -e "######## \e[01;33m End building $SUDO_PACKAGE \e[00m ########\n"
}


#Re-build busybox option
#build_busybox



preprocess
build_ncurses
build_xz
build_zlib
build_ffi
build_glib
build_expat
build_dbus
build_cap
build_util_linux
build_gpg_error
build_gcrypt
build_curl
build_kmod
build_lz4
build_sudo
