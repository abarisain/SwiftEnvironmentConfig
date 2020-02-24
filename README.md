# EnvironmentConfig

![swift](https://img.shields.io/badge/Swift-5.1-orange.svg)
![platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Linux%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)
![version](https://img.shields.io/github/v/release/abarisain/SwiftEnvironmentConfig?include_prereleases)
![GitHub Workflow Status - macOS](https://img.shields.io/github/workflow/status/abarisain/SwiftEnvironmentConfig/macOS?label=macOS%20build)
![GitHub Workflow Status - Linux](https://img.shields.io/github/workflow/status/abarisain/SwiftEnvironmentConfig/Linux?label=linux%20build)

EnvironmentConfig is a Swift library that allows you to parse environement variables into a struct, converting them if needed and possible.
It allows for eager loading of the configuration, and can be made to volountarily crash your program early if a missing variable is needed.

The library uses property wrappers as java-like annotations to achieve this.

## Using it in your project

This library is distributed using SwiftPM:
```Swift
.package(url: "https://github.com/abarisain/SwiftEnvironmentConfig.git", from: "1.0.0-beta1")
```

## Usage

EnvironmentConfig can be used in two ways:
- Implicitly, where the library will try to guess the name of the environment variable from the field name.
- Explicitly, where you provide the expected name. The library will only try lower/uppercase versions of the name on your behalf.

### Implicit names

```Swift
struct Config {
    @EnvField()
    var user: String
    
    @EnvField()
    var password: String
}

// You can catch EnvironmentConfigError.unparsableOrMissingValue to see
// why the library failed to load your variables.
let config = Config()
// The library will try to read from user, USER, password and PASSWORD
try EnvironmentConfig.load(config)
```

Prefixes are supported:
```Swift
struct Config {
    @EnvField()
    var user: String
    
    @EnvField()
    var password: String
}

let config = Config()
// The library will try to read from mysql_user, MYSQL_USER, mysql_password and MYSQL_PASSWORD
try EnvironmentConfig.load(config, prefix: "mysql")
```

The library will also try to convert camel cased fields to snake case:

```Swift
struct Config {
    @EnvField()
    var databaseName: String?
}

// The library will try to read: databaseName, DATABASENAME, databasename, database_name, DATABASE_NAME
let config = Config()
try EnvironmentConfig.load(config)
```

### Explicit names

If you only use explicit keys, you don't have to call `.load()`: 

```Swift
struct Config {
    @EnvField(name: "mysql_user")
    var user: String
    
    @EnvField(name: "mysql_password")
    var password: String
}

// All values will be eagerly fetched at instanciation
// Any non optional value will no default value will crash the program.
let config = Config()
```

>Note: if you mix implicit and explicit names, `.load()` will only throw an error for implicit names. Explicit ones will still crash the program as soon as your struct is instanciated.

### Default values

The library supports setting default values:

```Swift
struct Config {
    @EnvField(defaultValue:"user")
    var user: String
    
    @EnvField(name: "mysql_password", defaultValue: "secret")
    var password: String
}

// Will not crash, even if the environment variables are missing
let config = Config()
try EnvironmentConfig.load(config, prefix: "mysql")
```

Optionals are of course supported:
```Swift
struct Config {
    @EnvField(defaultValue:"user")
    var user: String?
    
    @EnvField(name: "mysql_password")
    var password: String?
}

// Will not crash, even if the environment variables are missing
let config = Config()
try EnvironmentConfig.load(config, prefix: "mysql")
```

## Supported types

As of writing, the library supports the following types:
 - String
 - Int/UInt (Int8, Int16, ...)
 - Bool ("1", "true" or "TRUE" for true, "0", "false" or "FALSE" for false)
 
Note that any other type than String can fail to be converted, in which case the library will throw `EnvironmentConfigError.unparsableOrMissingValue`.

### Adding your own supported type

Any type that conforms to EnvironmentValueInitializable can be used with @EnvField.

Example of an extension that allows a Data to be initialized by its hexadecimal representation if it begins with "0x":
```Swift
import Foundation

extension Data: EnvironmentValueInitializable {
    public static func from(envValue hexString: String) -> Any? {
        var startIndex = hexString.startIndex
        if !hexString.hasPrefix("0x") {
            return nil
        }
        startIndex = hexString.index(startIndex, offsetBy: 2)
        var data = Data()
        while startIndex < hexString.endIndex {
            let endIndex = hexString.index(startIndex, offsetBy: 2, limitedBy: hexString.endIndex) ?? hexString.endIndex
            var substr = hexString[startIndex ..< endIndex] // 1 or 2 bytes
            if substr.count == 1 {
                // Assume 0 for the 2nd char
                substr += "0"
            }
            data.append(UInt8(substr, radix: 16)!)
            startIndex = endIndex
        }
        return data
    }
}
```

## Roadmap

- [ ] Array support
- [ ] Support nested structs (if possible)

## Credits

This library has been inspired by [Environment](https://github.com/wlisac/environment)
It's basically a lighter version of it, that allows the program to crash early if a variable is missing.
This lightens the noisiness of optional checking (or empty default values) for configuration that a program cannot run without.
It also adds implicit names.

The need for this library came from using [envconfig](https://github.com/vrischmann/envconfig) and wanting a Swift version of it.
