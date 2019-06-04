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

## app: use libs in rootProject

    repositories {

        flatDir {
            dirs '../libs'
        }
    }
