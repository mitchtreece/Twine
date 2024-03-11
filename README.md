![Twine](Assets/Banner.png)

<div align="center">

![Version](https://img.shields.io/badge/Version-1.0.2-BDD7FF.svg?style=for-the-badge&labelColor=166CE3)
![Xcode](https://img.shields.io/badge/Xcode-15-BDD7FF.svg?style=for-the-badge&labelColor=166CE3)
![Swift](https://img.shields.io/badge/Swift-5.9-BDD7FF.svg?style=for-the-badge&labelColor=166CE3)
![iOS](https://img.shields.io/badge/iOS-16+-BDD7FF.svg?style=for-the-badge&labelColor=166CE3)
![macOS](https://img.shields.io/badge/macOS-13+-BDD7FF.svg?style=for-the-badge&labelColor=166CE3)

</div>

# Twine

Lightweight helper library & command-line tool that makes working
with Xcode string catalogues (xcstrings) & localized strings a breeze 🧶

## Installation

### SPM

The easiest way to get started is by installing via Xcode. 
Just add Twine as a Swift package dependency.

If you're adding Twine as a dependency of your own Swift package, 
just add a package entry to your dependencies.

```swift
.package(
    name: "Twine",
    url: "https://github.com/mitchtreece/Twine",
    .upToNextMajor(from: .init(1, 0, 0))
)
```

## XCTwine

The `xctwine` command-line tool is extremely lightweight.
At its simplest, it can be used with only input & output file arguments:

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
will generate string-keys in a given format. `xctwine` supports
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
for easy integration with your pipeline. After installation, 
just add it to your target's build-tool plugin list under:

- `Project → Targets → Build Phases → Run Build-Tool Plugins`

## @Localized

In addition to the tool, this package also includes a small
helper library containing a `@Localized` property-wrapper for easy 
localized-string lookup...

```swift
import Twine

@Localized var myLocalizedString: String = "MY_STRING"
```

...and when combined with `xctwine` generated string-extensions,
localized string initialization is as clean & simple as

```swift
import Twine

@Localized var myLocalizedString: String = .myString
```

## Contributing

Pull-requests are more than welcome. 
Bug fix? Feature? Open a PR and we'll get it merged in! 🎉
