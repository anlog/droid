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

