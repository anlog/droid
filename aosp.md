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

