#!/bin/bash

copy_dir=/tmp/htmlbackup
listen_addr=0.0.0.0:18888


if ! test $1
then
    echo "Usage: ./run.sh /tmp/backuphtml"
    exit
fi
dir=`pwd`

use_copy=true

target_dir=$1

if test $1 = "-r"
then
    if ! test $2
    then
        echo "Usage: ./run.sh /tmp/backuphtml"
        exit
    fi
    target_dir=$2
    use_copy=false
fi

if test $2 && test $2 = "-r"
then
    if ! test $1
    then
        echo "Usage: ./run.sh /tmp/backuphtml"
        exit
    fi
    target_dir=$1
    use_copy=false
fi

if $use_copy
then
    printf "Cleaning Up...."
    echo "OK"
    rm -rf $copy_dir
    printf "Copying files...."
    cp -r $target_dir $copy_dir
    target_dir=$copy_dir
    echo "OK"
fi

cd $target_dir

# fix "date(): Timezone database is corrupt" error
mkdir -p usr/lib/locale
mkdir -p usr/share/zoneinfo
cp -r /etc/localtime etc/ 2>/dev/null
cp -r /usr/share/zoneinfo/ usr/share/ 2>/dev/null

echo "Starting PHP server.."
cmd="env FAKECHROOT_BASE=$target_dir LD_PRELOAD=$dir/libfakechroot.so php -S $listen_addr"
echo $cmd
$cmd