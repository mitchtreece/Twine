![Lumberjack](Assets/Banner.png)

<div align="center">

![Version](https://img.shields.io/badge/Version-1.0.0-BDD7FF.svg?style=for-the-badge&labelColor=166CE3)
![Xcode](https://img.shields.io/badge/Xcode-15-BDD7FF.svg?style=for-the-badge&labelColor=166CE3)
![Swift](https://img.shields.io/badge/Swift-5.7-BDD7FF.svg?style=for-the-badge&labelColor=166CE3)
![macOS](https://img.shields.io/badge/macOS-13+-BDD7FF.svg?style=for-the-badge&labelColor=166CE3)

</div>

# XCTwine

Lightweight Swift command-line tool that helps translate localized
Xcode string files (xcstrings) into typed string extensions 🧶

## Installation

### SPM

The easiest way to get started is by installing via Xcode. 
Just add XCTwine as a Swift package dependency.

If you're adding XCTwine as a dependency of your own Swift package, 
just add a package entry to your dependencies.

```swift
.package(
    name: "XCTwine",
    url: "https://github.com/mitchtreece/XCTwine",
    .upToNextMajor(from: .init(1, 0, 0))
)
```

## Usage

XCTwine is extremely lightweight - at its simplest, 
it can be used with only input & output file arguments:

- `$ xctwine Localizable.xcstrings String+Localized.swift`

The generated `String+Localized.swift` file will look something like...

```swift
extension String {
    static let myString: String = "MY_STRING"
}
```

...which can then be referenced directly in your project

```swift
var myLocalizedString: String = .myString
```

### Formatting

Specifying an output format with the `--format` or `-f` options
will generate string-keys in that given format. XCTwine supports
the following formats:

- `none`: No key formatting
- `camel`: Camel-cased keys
- `pascal`: Pascal-cased keys

Given the input key `MY_STRING`, the various formats would translate to:

- `none` → `MY_STRING` → `MY_STRING`
- `camel` → `MY_STRING` → `myString`
- `none` → `MY_STRING` → `MyString`

### Namespaces

Specifying a namespace with the `--namespace` or `-n` options
will generate string-keys in a wrapped namespace - instead of
directly as an extension on `String`. For example, the following
command:

- `$ xctwine Localizable.xcstrings String+Localized.swift --namespace=localized`

Will generate a `String+Localized.swift` file that looks something like...

```swift
extension String {

    struct XCTwine {
        let myString: String = "MY_STRING"
    }

    var localized: XCTwine {
        return XCTwine()
    }

}
```

...which can then be referenced directly in your project like

```swift
var myLocalizedString: String = .localized.myString
```

## Contributing

Pull-requests are more than welcome. Bug fix? Feature? Open a PR and we'll get it merged in! 🎉
