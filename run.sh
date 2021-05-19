#!/bin/bash

copy_dir="/tmp/htmlbackup"
listen_addr="0.0.0.0:18888"


if ! test $1
then
    echo "Usage: ./run.sh /tmp/backuphtml"
    exit
fi
dir=$(pwd)

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
    cp -r "$target_dir" $copy_dir
    target_dir=$copy_dir
    echo "OK"
fi

cd $target_dir || exit

# fix "date(): Timezone database is corrupt" error
mkdir -p usr/lib/locale
mkdir -p usr/share/zoneinfo
cp -r -L /etc/localtime etc/ 2>/dev/null
cp -r -L /usr/share/zoneinfo/ usr/share/ 2>/dev/null

# load php config and plugins
php_config_path=$(php -r 'echo dirname(php_ini_loaded_file());')
ext_path=$(php -r 'echo ini_get("extension_dir");')
mkdir -p $(eval "php -r 'echo dirname(\"${php_config_path:1:999}\");'")
mkdir -p $(eval "php -r 'echo dirname(\"${ext_path:1:999}\");'")
cp -r -L "$php_config_path" "${php_config_path:1:999}"
cp -r -L "$ext_path" "${ext_path:1:999}"

echo "Starting PHP server.."
cmd="env FAKECHROOT_BASE=$target_dir LD_PRELOAD=$dir/libfakechroot.so php -S $listen_addr"
echo "$cmd"
$cmd
