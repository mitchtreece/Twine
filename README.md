![Twine](Assets/Banner.png)

<div align="center">

![Version](https://img.shields.io/badge/Version-1.0.3-BDD7FF.svg?style=for-the-badge&labelColor=166CE3)
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

- `$ xctwine Localizable.xcstrings Strings.swift`

The generated `Strings.swift` file will look something like...

```swift
extension StringProtocol where Self == String {

    static var helloWorld: LocalizedStringEntry { .init(key: "HELLO_WORLD") }

}
```

...and can then be referenced directly in your project

```swift
let messageKey: String = .helloWorld.key
let messageValue: String = .helloWorld.value(...)
```

### Namespaces

Specifying a namespace with the `--namespace` or `-n` options
will generate string-keys in a wrapped enum type accessible via,
a static string helper function. For example, the following command:

- `$ xctwine Localizable.xcstrings Strings.swift --namespace=loc`

Will generate a `Strings.swift` file that looks something like...

```swift
enum LocLocalizationKey: String, CaseIterable {

    case helloWorld = "HELLO_WORLD"

}

extension StringProtocol where Self == String {

    static func loc(_ key: LocLocalizationKey) -> LocalizedStringEntry {
        return .init(key: key.rawValue)
    }

}
```

...and then can be referenced directly in your project like:

```swift
let messageKey: String = .loc(.helloWorld).key
let messageValue: String = .loc(.helloWorld).value(...)
```

In addition to the above, specifying the `--namespaceKey` or `-k` options
will use an explicit name for the generated namespace's enum type. i.e.
`LocLocalizationKey` -> `MyCustomKey`.

### Namespace Keys

Specify

### Formatting

Specifying an output format with the `--format` or `-f` options
will generate string-keys in a given format. `xctwine` supports
the following formats:

- `none`: No key formatting
- `camel`: Camel-cased keys
- `pascal`: Pascal-cased keys

Given the input key `HELLO_WORLD`, the various formats would translate to:

- `none` → `HELLO_WORLD` → `HELLO_WORLD`
- `camel` → `HELLO_WORLD` → `helloWorld`
- `pascal` → `HELLO_WORLD` → `HelloWorld`

### Module Extensions

Specifying a flag with the `--moduleExt` or `-m` options will generate
`Bundle.module` extensions for use with the other helper property-wrappers
& macros listed below. This is useful when you are localizing strings across 
multiple packages & modules. For example, with these extensions, the following...

```swift
"HELLO_WORLD".localized(bundle: .module)
.helloWorld.value(bundle: .module)
.loc(.helloWorld).value(bundle: .module)
```

...Could be simplified to:

```swift
"HELLO_WORLD".localized
.helloWorld.value
.loc(.helloWorld).value
```

### Public Access

By default, generated types have an `internal` (unspecified) access-level.
However, specifying the `--public` or `-p` options will generate `public`
types. i.e.

```swift
public extension StringProtocol where Self == String {

    static var helloWorld: LocalizedStringEntry { .init(key: "HELLO_WORLD") }

}
```

### Config File

Specifying the config file with the `--config` or `-c` options will load
arguments from a file, instead of the command-line. This is useful when
using `xctwine` via the Xcode build plugin listed below. Config files must
be named either `xctwine` _or_ `xctwine.json`, be json formatted, and contain
the following fields:

```json
{
  "namespace": "string",
  "format": "none | camel | pascal",
  "moduleExt": true | false,
  "public": true | false
}
```

## Xcode Plugin

`xctwine` also comes packaged as an Xcode build plugin 
for easy integration with your pipeline. After installation, 
just add it to your target's build-tool plugin list under:

- `Project → Targets → Build Phases → Run Build-Tool Plugins`

To customize built-time arguments, add a configuration file
(`xctwine` | `xctwine.json`) to your module's source files.

## Helpers

In addition to the executable & build-tool, this package also
includes a small helper module containing some property-wrappers & macros.

### @Localized

`@Localized` is a property-wrapper for easy localized-string lookup

```swift
import Twine

@Localized var literalString: String = "HELLO_WORLD"
@Localized var twineString: String = .helloWorld
```

## String+Localized

If the above property-wrapper doesn't fit your needs, or you need
inline access to localized strings, `xctwine` also includes some
direct string extensions to make your life easier.

```swift
import Twine

let literalString: String = "HELLO_WORLD".localized(...)
let twineString: String = .helloWorld.value(...)
```

## Contributing

Pull-requests are more than welcome. 
Bug fix? Feature? Open a PR and we'll get it merged in! 🎉
