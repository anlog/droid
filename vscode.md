### for aosp c/c++ service for clangd

```
"C_Cpp.intelliSenseEngine": "Disabled",
    "C_Cpp.autocomplete": "Disabled", // So you don't get autocomplete from both extensions.
    "C_Cpp.errorSquiggles": "Disabled", // So you don't get error squiggles from both extensions (clangd's seem to be more reliable anyway).
    "clangd.path": "/usr/bin/clangd-10",
    "clangd.arguments": [
        "-log=verbose",
        "-pretty",
        "--background-index",
        "--compile-commands-dir=/home/dp/code/master/out/soong/development/ide/compdb"
    ],
```
