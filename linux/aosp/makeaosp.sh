#!/usr/bin/zsh
## constants
aosppath=/home/dp/code/master
kernelpath=/home/dp/code/kernel

## for aosp kernel build
function makekernel() {
    kpath=${kernelpath:-/home/dp/code/kernel}
    echo "building kernel for aosp at ${kpath}"
    cd ${kpath} && \
        repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags && \
        BUILD_CONFIG=goldfish-modules/build.config.goldfish.x86_64 build/build.sh && \
        ./common/scripts/gen_compile_commands.py -d out/android-5.4/common -o out/android-5.4/dist/compile_commands.json &&  mkdir -p out/$(date +%Y%m%d) && \
        tar -caf out/$(date +%Y%m%d)/kernel_$(date +%Y%m%d_%H%M%S).tar.gz -C out/android-5.4 --exclude "*vmlinux" dist &&  \
        bpy upload out/$(date +%Y%m%d) || bpy notify "kernel failed: $(journalctl -a  _SYSTEMD_INVOCATION_ID=$(systemctl show -p InvocationID --value aosp) | tail -10)"
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
        source build/envsetup.sh && lunch sdk_phone_x86_64-userdebug && m sdk && \
        mkdir -p out/$(date +%Y%m%d) && \
        cp out/host/linux-x86/sdk/sdk_phone_x86_64/android-sdk_eng.dp_linux-x86.zip* out/$(date +%Y%m%d) && \
        zip out/$(date +%Y%m%d)/compile_commands.json.zip out/soong/development/ide/compdb/compile_commands.json && \
        zip -qr out/$(date +%Y%m%d)/clion.zip out/development/ide/clion && \
        cp out/verbose.log.gz out/$(date +%Y%m%d) && \
        journalctl -a  _SYSTEMD_INVOCATION_ID=$(systemctl show -p InvocationID --value aosp) > out/$(date +%Y%m%d)/aosp.build.log && \
        aosp_take_gen out out/$(date +%Y%m%d) && \
        bpy upload out/$(date +%Y%m%d) || bpy notify "aosp failed: $(journalctl -a  _SYSTEMD_INVOCATION_ID=$(systemctl show -p InvocationID --value aosp) | tail -10)"
    ulimit -S -n ${oldlimit}

}

func aosp_take_gen() {

    [ $1 ] || { echo "you must specific the <out> dir" && return 1 }

    target=$1/soong/.intermediates

    gen_dir=$(dirname ${target})/gen/
    rmdir ${gen_dir}
    for i in $(find ${target} -path "*gen*/*.java" -not -path "*stubs*" -not -path "*R.java" ); do
        package_name=$(cat $i | grep "package " | cut -f 2 -d ' ' |cut -f 1 -d ';' )
        package_dir=${package_name//.//}
        package_gen_dir=${gen_dir}/${package_dir}
        echo "copying $i -> ${package_gen_dir}"
        [ ${package_dir} ] && mkdir -p ${package_gen_dir} && cp $i ${package_gen_dir}
    done

    src_jar_dir=$(dirname ${target})/srcjar/
    rmdir ${src_jar_dir}
    find ${target} -path "*gen*/*.srcjar" -not -path "*stub*" -exec unzip -o {} -d ${src_jar_dir} \;

    ## then tar them
    tar -caf ${2:-.}/gen.tar.gz ${gen_dir} ${src_jar_dir} && \
    echo "create ${2:-.}/gen.tar.gz for ${gen_dir} & ${src_jar_dir} success"
}

## main
# If running interactively, don't do anything
[[ "$-" == *i* ]] && return
makekernel
makeaosp
