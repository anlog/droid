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
