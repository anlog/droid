## droid: 80fixsim: Fake carrier for ROMs with init.d support

 - MCC & MNC: http://www.mcc-mnc.com/ & https://wammu.eu/tools/networks/?country=310

## aosp: import-android-studio-howto

 - https://wiki.lineageos.org/usinggerrit-howto.html
 
## app: using getVersionName & getVersionCode in gradle

```
def getVersionName() {
    def count = 'git rev-list HEAD --count'.execute().text.trim().toInteger()
    return ext.masterVersion + '.' + count
}
```
```
def getVersionCode() {
    def versionSplite = getVersionName().split("\\.")
    return versionSplite[0].toInteger() * 100000 + versionSplite[1].toInteger()
}
```

## app: use libs in rootProject gradle

    repositories {

        flatDir {
            dirs '../libs'
        }
    }
 
## app: compileOnly framework in gradle

```
dependencies {
    implementation fileTree(include: ['*.jar'], dir: 'libs')
    compileOnly(name: 'framework')
}
```
```
preBuild {
    doLast {
        def imlFile = file(project.name + ".iml")
        println 'Change ' + project.name + '.iml order'
        try {
            def parsedXml = (new XmlParser()).parse(imlFile)
            def jdkNode = parsedXml.component[1].orderEntry.find { it.'@type' == 'jdk' }
            parsedXml.component[1].remove(jdkNode)
            def sdkString = "Android API " + android.compileSdkVersion.substring("android-".length()) + " Platform"
            new Node(parsedXml.component[1], 'orderEntry', ['type': 'jdk', 'jdkName': sdkString, 'jdkType': 'Android SDK'])
            groovy.xml.XmlUtil.serialize(parsedXml, new FileOutputStream(imlFile))
        } catch (FileNotFoundException e) {
            // nop, iml not found
        }
    }
}
```
## droid: print only package_name logcat
```
function alog() {
    package=${1:-system_server}
    while true
    do
        pid=$(adb shell pidof $package)
        # pid=$(adb shell ps -ef |grep $package | awk -F ' ' '{print $2}' | head -1)
        if [ -n "$pid" ]; then
            break;
        else
            sleep 0.5
        fi
    done

    adb logcat -v threadtime -v color --pid=${pid}
}
```
## droid: using fastboot to update system
```
fastboot flash boot boot.img
fastboot flash aboot emmc_appsboot.mbn
fastboot flash system system.img
fastboot flash userdata userdata.img
fastboot flash vendor vendor.img
```
## droid: qdl Qcom 9008 edl download

> https://www.96boards.org/documentation/consumer/guides/qdl.md.html

`qdl --debug --storage emmc ./prog_emmc_firehose_8996_ddr.elf rawprogram_unsparse.xml patch0.xml`

## aapt dump badging apk version

`~/Library/Android/sdk/build-tools/28.0.3/aapt dump badging *.apk |grep version`

## Android get imei

`service call iphonesubinfo 1 | toybox cut -d "'" -f2 | toybox grep -Eo '[0-9]' | toybox xargs | toybox sed 's/\ //g'`

## Android get route table

`ip route list match 0 table all scope global`

## Android get default route
```
for a in $(ip rule show | grep lookup | sed -r 's/.* lookup ([^ ]+).*/\1/'); do ip route show table $a | grep ^default | cut -d ' ' -f 2-5; done | head -1
```

## Android NDK cmake
```
cmake -S. -Bout -DCMAKE_BUILD_TYPE=Debug -DANDROID_ABI=arm64-v8a -DANDROID_NDK=/Users/dp/Library/Android/sdk/ndk-bundle -DCMAKE_BUILD_TYPE=Debug -GNinja -DCMAKE_TOOLCHAIN_FILE=/Users/dp/Library/Android/sdk/ndk-bundle/build/cmake/android.toolchain.cmake -DCMAKE_MAKE_PROGRAM=/usr/local/bin/ninja -DANDROID_NATIVE_API_LEVEL=23 -DCMAKE_C_FLAGS= -DCMAKE_CXX_FLAGS= -DANDROID_TOOLCHAIN=clang
```

## Android qdl images to one

```
rm -rf tmp.img && for i in $(seq 1 $(ls -Al system_*.img | wc -l)); do cat system_${i}.img >> tmp.img ; done
rm -rf tmp.img && for i in $(seq 1 $(ls -Al vendor_*.img | wc -l)); do cat vendor_${i}.img >> tmp.img ; done
```

## aosp ninja tool

`./prebuilts/build-tools/linux-x86/bin/ninja -f out/combined-M01_AE.ninja -t list`

## Android check settings

```
adb shell dumpsys settings | grep device_provisioned
```

## android dalvik

> android/Hello.java
```
javac Hello.java
java Hello

dx --dex --output=hello.dex Hello.class
adb push hello.dex /cache
dalvikvm -cp /cache/hello.dex Hello
art -cp /cache/hello.dex Hello
CLASSPATH=/cache/hello.dex exec app_process /system/bin Hello

dexdump -d hello.dex

baksmail d hello.dex
smail a -o a.dex out
```

## android br->data->img

```
~/code/dipper/out/soong/host/linux-x86/bin/brotli  -d vendor.new.dat.br -o vendor.new.dat
python sdat2img.py system.transfer.list system.new.dat system.img
python sdat2img.py vendor.transfer.list vendor.new.dat  vendor.img
```

# android skia build

```
git clone https://skia.googlesource.com/skia.git
# or
# fetch skia
cd skia
python2 tools/git-sync-deps

# for arm64 build
bin/gn gen out/arm64 --args='ndk="/home/dp/Android/Sdk/ndk-bundle" target_cpu="arm64" target_os="android" is_official_build=true is_component_build=true is_debug=false skia_use_system_expat=false  skia_use_system_freetype2=false skia_use_system_libpng=false skia_use_icu=false skia_use_libjpeg_turbo=false skia_use_libwebp=false skia_use_piex=false'

ninja -C out/arm64
# use nm to find undefined symbol
nm -u out/arm64/libskia.so

# strip unused code
~/Android/Sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-strip --strip-unneeded out/arm64/libskia.so

# for arm build
bin/gn gen out/arm --args='ndk_api=21 ndk="/home/dp/Android/Sdk/ndk-bundle" target_cpu="arm" target_os="android" is_official_build=true is_component_build=true is_debug=false skia_use_system_expat=false  skia_use_system_freetype2=false skia_use_system_libpng=false skia_use_icu=false skia_use_libjpeg_turbo=false skia_use_libwebp=false skia_use_piex=false'

ninja -C out/arm
# strip unused code
~/Android/Sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android-strip --strip-unneeded out/arm/libskia.so
```
# proguard common issues

```
混淆常见错误; 目前遇到了2种:
1. 主动调用的方法
不能用反射, 因为经过混淆后的代码, 你不能确定方法名(包括类名,变量等)不变, 会导致 MethodNotFoundException
2. use-library 添加的 callback 实现类 不能混淆
如果是静态引入的sdk 这样的混淆没问题; 但是使用use-library 的动态库; 回调时load 进来的class 执行 mCallBack.onXXX(); 方法时
你在本地代码实现的 CallBack 实现类 的方法被混淆了, 导致出错;  会导致 AbstraceMethodError

-keep class * implements com.example.*
```

# aosp manifest merger cli

```
java -classpath prebuilts/devtools/tools/lib/manifest-merger.jar com.android.manifmerger.Main merge --main main/AndroidManifest.xml --libs libs/AndroidManifest.xml  -o  /tmp/merger.xml
```

# Qcom Boot Process [https://lineageos.org/engineering/Qualcomm-Firmware/](https://lineageos.org/engineering/Qualcomm-Firmware/)
