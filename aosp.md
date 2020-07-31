## asop [https://source.android.com/setup/build/initializing](https://source.android.com/setup/build/initializing)

```
repo init -u https://android.googlesource.com/platform/manifest -b master
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

source build/envsetup.sh
lunch sdk_phone_x86_64-userdebug
make -j$(nproc --all)

emulator
```

### kernel [https://source.android.com/setup/build/building-kernels](https://source.android.com/setup/build/building-kernels)

```
## init source code
repo init -u https://android.googlesource.com/kernel/manifest -b common-android-5.4
repo sync -j $(nproc -all)

## build
BUILD_CONFIG=goldfish-modules/build.config.goldfish.x86_64 build/build.sh

## setup the new kernel
mkdir ~/code/master/prebuilts/qemu-kernel/x86_64/5.4_LOCAL

ln -sf ~/code/kernel/out/android-5.4/dist/bzImage ~/code/master/prebuilts/qemu-kernel/x86_64/5.4_LOCAL/kernel-qemu2
ln -sf ~/code/kernel/out/android-5.4/dist ~/code/master/prebuilts/qemu-kernel/x86_64/5.4_LOCAL/ko

## patch device tree

> `patch_device_generic_goldfish.txt` you can found in the repo

`cd device/generic/goldfish && git apply patch_device_generic_goldfish.txt`

## now build aosp again
source build/envsetup.sh
lunch sdk_phone_x86_64-userdebug
make -j$(nproc --all)
emulator
adb shell cat /proc/version
```

## make kernel module outside

> you can follow this [`Makefile`](./android/aosp/Makefile)

```
export PATH=${HOME}/code/master/prebuilts/clang/host/linux-x86/clang-r383902/bin:${HOME}/code/master/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin:${PATH}

make -C /home/dp/code/dipper/out/target/product/dipper/obj/KERNEL_OBJ M=/home/dp/code/wg/wireguard-linux-compat/src O=/home/dp/code/wg/wireguard-linux-compat/src/out ARCH=arm64 CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-androidkernel- CROSS_COMPILE_ARM32=aarch64-linux-androidkernel- WIREGUARD_VERSION="1.0.20200611-dirty" modules
```

## attach android process with visual studio code

```
adb forward --list

 adb forward tcp:5005 jdwp:$(adb shell pidof system_server) && jdb -attach localhost:5005

 # use func
 function aadb() {
    proc_name=${1:-system_server} # default proc_name to debug
    port=${2:-5005} # default port to forward
    forwarded=$(adb forward --list | grep -q "jdwp:${port}" | cut -f 2 -d ' ')
    [ ${forwarded} ] && adb forward --remove ${forwarded}
    adb forward tcp:${port} jdwp:$(adb shell pidof ${proc_name}) && jdb -attach localhost:${port}
}

[funcs for mime](./linux.zsh_func)
```

> [vscode debug launch.json](./android/aosp/.vscode/launch.json)

## aosp tar output for ide

```
# for source code you may need
tar -cf ../dipper.tar.gz frameworks packages libcore hardware bionic  art build bootable dalvik  development device libcore libnativehelper system vendor/aosp vendor/codeaurora vendor/nxp vendor/qcom aosp.iml aosp.ipr

# for generate protobuf or aidl things
find out/soong -path "*gen*/*.java" -not -path "*stubs*" -not -path "*R.java" -or -path "*gen*/*.srcjar" -not -path "*stub*" |tar -cavf out.tar.gz -T -

tar -xzf out.tar.gz -C dipper

# unzip srcjar to srcjar
find out -name "*.srcjar" -exec unzip -o {} -d out/soong/srcjar \;

---

# V1: for aosp_get_out from findout
func aosp_get_out() {

    [ $1 ] || { echo "you must specific the <out> dir" && return 1 }

    target=$1/soong/.intermediates

    gen_dir=$(dirname ${target})/gen/
    for i in $(find ${target} -path "*gen*/*.java" -not -path "*stubs*" -not -path "*R.java" ); do
        package_name=$(cat $i | grep "package " | cut -f 2 -d ' ' |cut -f 1 -d ';' )
        package_dir=${package_name//.//}
        package_gen_dir=${gen_dir}/${package_dir}
        echo "copying $i -> ${package_gen_dir}"
        [ ${package_dir} ] && mkdir -p ${package_gen_dir} && cp $i ${package_gen_dir}
    done

    src_jar_dir=$(dirname ${target})/srcjar/
    find ${target} -path "*gen*/*.srcjar" -not -path "*stub*" -exec unzip -o {} -d ${src_jar_dir} \;

    ## then tar them
    tar -caf out.tar.gz ${gen_dir} ${src_jar_dir} && \
    echo "create out.tar.gz for ${gen_dir} & ${src_jar_dir} success"
}



```

## how ibinder object transfered?

`https://cs.android.com/android/platform/superproject/+/master:frameworks/native/libs/binder/Parcel.cpp;drc=master;l=191`


## binder

```
local -> remote(mean driver indeed)
binder -> IXX.Stub.Proxy.transact -> BinderProxy.transact -> android_utils_Binder.cpp::android_os_BinderProxy_transact -> BpBinder.cpp::transact -> IPCThreadState::transact
```

## wireshark with android

```
M01_AE:/data # tcpdump -n -i usb0 -s 0 -w - | toybox nc -l -p 12345
打开另外一个窗口，运行下面的命令：
D:\temp>adb forward tcp:23456 tcp:12345 && nc 127.0.0.1 23456 | "C:\Program Files\Wireshark\Wireshark.exe" -k -S -i -
```
