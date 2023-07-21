#!/bin/sh

if [ $1 = "32" ]; then
    BIT=32
elif [ $1 = "64" ]; then
    BIT=64
fi

BUILDSYS_DIR=${BUILD_PLATFORM_PATH}
ROOT_DIR=`pwd`
CPU_CORE=32

TEMPDIR=$ROOT_DIR/tmp_install
PREBUILD_DIR=$ROOT_DIR/install

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
        cd $BUILDSYS_DIR/../../bin/oolchain
        tar -xzf $BUILDSYS_DIR/../../bin/toolchain/linaro_aarch64_linux-2014.09_r20170413.tar.gz
    fi
    export PATH=$BUILDSYS_DIR/../../bin/toolchain/linaro_aarch64_linux-2014.09_r20170413/bin/:$PATH
    TOOLCHAIN=${TOOLCHAIN:-"aarch64-linux-gnu-"}
    HOST="aarch64-linux-gnu"
fi


function strip_libs()
{
    cd $TEMPDIR
    if [ "$BIT" = "32" ]; then
        for i in `find ./ -type f ! -name "*.ko"`;
        do
           if [ "`file $i | grep -Eo 'ELF'`" != "" ]; then
              #echo $i
              ${HOST}-strip --strip-debug --strip-unneeded --remove-section=.comment --remove-section=.note --preserve-dates $i
           fi;
        done
    elif [ "$BIT" = "64" ]; then
        for i in `find ./ -type f ! -name "*.ko"`;
        do
           if [ "`file $i | grep -Eo 'ELF'`" != "" ]; then
              #echo $i
              ${HOST}-strip --strip-debug --strip-unneeded --remove-section=.comment --remove-section=.note --preserve-dates $i
           fi;
        done
    fi
}

function delete_unused_files()
{
    cd $TEMPDIR
    find $TEMPDIR -type f -name '*.h' | xargs -i cp -f {} $PREBUILD_DIR/header/
    find $TEMPDIR -type f -name '*.la' -delete
    find $TEMPDIR -type f -name '*.a' -delete
    find $TEMPDIR -type f -name '*.h' -delete
}

function postprocess()
{
    if [ "$BIT" = "32" ]; then
        echo -e "######## \e[01;33m copy 32 bit LIBs from $TEMPDIR to $PREBUILD_DIR \e[00m ########\n"
        cp -rf $TEMPDIR/* $PREBUILD_DIR/
    elif [ "$BIT" = "64" ]; then
        echo -e "######## \e[01;33m copy 64 bit LIBs from $TEMPDIR to $PREBUILD_DIR \e[00m ########\n"
        cp -rf $TEMPDIR/lib/* $PREBUILD_DIR/lib64/
    fi
}

strip_libs
delete_unused_files
postprocess

