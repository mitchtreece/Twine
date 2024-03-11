![Lumberjack](Assets/Banner.png)

<div align="center">

![Version](https://img.shields.io/badge/Version-1.0.0-BDD7FF.svg?style=for-the-badge&labelColor=166CE3)
![Xcode](https://img.shields.io/badge/Xcode-15-BDD7FF.svg?style=for-the-badge&labelColor=166CE3)
![Swift](https://img.shields.io/badge/Swift-5.9-BDD7FF.svg?style=for-the-badge&labelColor=166CE3)
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

- `$ xctwine Localizable.xcstrings String+Localizable.swift`

The generated `String+Localizable.swift` file will look something like...

```swift
public extension String {
    static let myLocalizedString: String = "MY_STRING"
}
```

...which can then be referenced directly in your project

```swift
var myLocalizedString: String = .myString
```

### Formatting

Specifying an output format with the `--format` or `-f` options
will generate string-keys in a given format. XCTwine supports
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

- `$ xctwine Localizable.xcstrings String+Localizable.swift --namespace=localized`

Will generate a `String+Localizable.swift` file that looks something like...

```swift
public extension String {

    struct XCTwine {
        public let myString: String = "MY_STRING"
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

## Xcode Plugin

XCTwine also comes packaged as an Xcode build plugin 
for easy integration with your build pipeline.
After installing XCTwine, just add it to your target's
build-tool plugin list under:

- `Project → Targets → Build Phases → Run Build-Tool Plugins`

## @Localized

In addition to the tool, this package also includes a `Localized`
module with a small `@Localized` property-wrapper for easy 
localized-string lookup...

```swift
@Localized var myLocalizedString: String = "MY_STRING"
```

...and when combined with XCTwine's generated string-extensions,
localized string initialization is as clean & simple as

```swift
@Localized var myLocalizedString: String = .myString
```

## Contributing

Pull-requests are more than welcome. 
Bug fix? Feature? Open a PR and we'll get it merged in! 🎉
