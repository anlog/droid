#!/usr/bin/zsh
## constants
aosppath=/home/dp/code/master
kernelpath=/home/dp/code/kernel

token=$(cat /home/dp/code/droid/linux/aosp/.token)

function tell() {
    curl 'https://oapi.dingtalk.com/robot/send?access_token='"${token:-$(cat /home/dp/code/droid/linux/aosp/.token)}" \
        -H 'Content-Type: application/json' \
        -d '{"msgtype": "text","text": {"content": "'"$1 build $2"'"}, "at": {"isAll": true}}'
}

## for aosp kernel build
function makekernel() {
    kpath=${kernelpath:-/home/dp/code/kernel}
    echo "building kernel for aosp at ${kpath}"
    cd ${kpath} && \
        repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags && \
        BUILD_CONFIG=goldfish-modules/build.config.goldfish.x86_64 build/build.sh
    tell "kernel" $(test $? -eq 0 && echo "ok" || echo "failed")
}

## for aosp master build
function makeaosp() {
    spath=${aosppath:-/home/dp/code/master}
    ## for gen clion CMakefile
    # https://android.googlesource.com/platform/build/soong/+/HEAD/docs/clion.md
    export SOONG_GEN_CMAKEFILES=1
    export SOONG_GEN_CMAKEFILES_DEBUG=1

    ## for gen compdb
    # https://android.googlesource.com/platform/build/soong/+/HEAD/docs/compdb.md
    export SOONG_GEN_COMPDB=1
    export SOONG_GEN_COMPDB_DEBUG=1

    oldlimit=$(ulimit -S -n)
    ulimit -S -n 2048
    echo "building master for aosp at ${spath}"
    cd ${spath} && \
        repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags && \
        source build/envsetup.sh && lunch aosp_x86_64-userdebug && m sdk
    tell "asop master" $(test $? -eq 0 && echo "ok" || echo "failed")
    ulimit -S -n ${oldlimit}
}


## todo for upload

## notify someone

## main
# If running interactively, don't do anything
[[ "$-" == *i* ]] && return
makekernel
makeaosp
