//
//  XCTwine.swift
//  XCTwine
//
//  Created by Mitch Treece on 3/8/24.
//

import Foundation
import ArgumentParser
import Rainbow

// BaseApp/AppFeatures_AppFeature_Debug.bundle
// appfeatures.AppFeature-Debug.resources

@main
struct XCTwine: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "xctwine",
        abstract: "A Swift command-line tool for translating xcstring catalogue's into typed string extensions"
    )
    
    @Argument(help: "The input xcstrings file")
    private var inputFile: File
    
    @Argument(help: "The generated output strings file")
    private var outputFile: File
    
    @Argument
    private var bundleName: String?
    
    @Option(
        name: [
            .customShort("c"),
            .customLong("config")
        ],
        help: "A configuration file to use instead of command-line arguments"
    )
    private var configFile: File?
    
    ////////////////////////////
    
    @Option(
        name: .shortAndLong,
        help: "An optional namespace alias to generate"
    )
    private var alias: String?
    
    @Option(
        name: [
            .customShort("b"),
            .customLong("category")
        ],
        help: "An optional namespace category to generate"
    )
    private var category: String?
    
    @Option(
        name: .shortAndLong,
        help: "The output key format [none, camel, pascal]"
    )
    private var format: KeyFormat = .camel
    
    @Flag(
        name: .shortAndLong,
        help: "Flag indicating if module extensions should be generated"
    )
    private var moduleExt: Bool = false
    
    private var xcConfig: Config!
    private static let stringsFileExtension: String = "xcstrings"
    private static let swiftFileExtension: String = "swift"
    
    mutating func run() throws {
                
        guard self.inputFile.exists else {
            error(.inputFileNotFound)
            return
        }
        
        guard let inputExtension = self.inputFile.extension,
              inputExtension == Self.stringsFileExtension else {
            
            error(.inputFileInvalidExtension)
            return
            
        }
        
        guard let outputExtension = self.outputFile.extension,
              outputExtension == Self.swiftFileExtension else {
            
            error(.outputFileInvalidExtension)
            return
            
        }
        
        log("🧶 Translating \(self.inputFile.name.green) → \(self.outputFile.name.green)")
        
        self.xcConfig = Config.from(
            file: configFile,
            alias: self.alias,
            category: self.category,
            format: self.format,
            moduleExt: self.moduleExt
        )
        
        if let configFile {
            log("⚙️ Using config file \(configFile.path.green)")
        }
        else {
            log("⚙️ Using config arguments")
        }
        
        if let alias = self.xcConfig.alias {
            log("   ﹂alias: \(alias.green)")
        }
        
        if let category = self.xcConfig.category {
            log("   ﹂category: \(category.green)")
        }
        
        log("   ﹂format: \(self.xcConfig.format.rawValue.green)")
        log("   ﹂moduleExt: \(self.xcConfig.moduleExt ? "true".green : "false".green)")
        
        guard let inputFileJson = File.json(self.inputFile) else {
            error(.inputFileJsonSerialization)
            return
        }
        
        guard let inputFileStringsJson = (inputFileJson["strings"] as? [String: Any])?.sorted(by: { $0.0 < $1.0 }) else {
            error(.inputFileInvalidJson)
            return
        }
        
        var entries = [StringEntry]()
        
        for (key, value) in inputFileStringsJson {
            
            let payload = value as? [String: Any]
            
            let duplicateKeyCount = entries.filter { entry in
            
                let existingKey = StringEntry.rawFormatKey(
                    entry.key,
                    format: self.xcConfig.format
                )
                
                let proposedKey = StringEntry.rawFormatKey(
                    key,
                    format: self.xcConfig.format
                )
                                
                return proposedKey == existingKey
                
            }
            .count
                        
            entries.append(StringEntry(
                key: key,
                format: self.xcConfig.format,
                comment: payload?["comment"] as? String,
                duplicateIndex: (duplicateKeyCount > 0) ? UInt(duplicateKeyCount) : nil
            ))
            
        }
        
        guard !entries.isEmpty else {
            error("No localization entries, exiting")
            return
        }
                
        // Input localization keys
        
        log("🔑 Found \(entries.count) localization entry(s)")
        
        for entry in entries {
            
            if let _ = entry.duplicateIndex {
                log("   ﹂\(entry.key.green) → \(entry.formattedKey.green)" + " (duplicate)".yellow)
            }
            else {
                log("   ﹂\(entry.key.green) → \(entry.formattedKey.green)")
            }
            
        }
        
        // Generate output file
        
        log("📝 Creating \(self.outputFile.name.green) extension file")
        
        let output = buildOutputString(entries: entries)
        
        guard let outputData = output.data(using: .utf8) else {
            error(.outputDataInvalid)
            return
        }
        
        do {
            
            try outputData
                .write(to: self.outputFile.pathUrl)
            
        }
        catch {
            self.error(.outputFileFailedToWrite)
        }
        
        // Done
        
        log("🎉 Successfully generated \(self.outputFile.path.green)")
        
    }
    
    // MARK: Private
    
    private func buildOutputString(entries: [StringEntry]) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        
        let dateString = formatter
            .string(from: Date())
        
        var string = """
        //
        // \(self.outputFile.name)
        //
        // Generated by XCTwine on \(dateString).
        // https://github.com/mitchtreece/XCTwine
        //
        
        import Foundation
        import Twine
        
        
        """
        
        if let alias = self.xcConfig.alias {
            
            string += "// MARK: Alias\n\n"
            string += "public typealias \(alias) = Twine\n\n"
            
        }
                
        if self.xcConfig.moduleExt {
            
//            fileprivate class MainBundleFinder {}
//            fileprivate let mainBundle = Bundle(for: MainBundleFinder.self)
            
            string += "// MARK: Module Extensions\n\n"

            if let bundleName {
                string += "fileprivate let bundle: Bundle = .init(identifier: \"\(bundleName)\")\n\n"
            }
            else {
                string += "fileprivate let bundle: Bundle = .module\n\n"
            }
            
            string += """
            public extension LocalizedStringEntry {
            
                /// Gets a localized string value in the current module.
                var value: String {
                    self.value(bundle: bundle)
                }
            
            }
            
            public extension Localized {
            
                /// Initializes the property-wrapper with a localized
                /// string key in the current module.
                init(wrappedValue: String) {
                    
                    self.init(
                        wrappedValue: wrappedValue,
                        bundle: bundle
                    )
            
                }
            
            }
            
            public extension String {
            
                /// Gets a localized string value in the current module.
                var localized: String {
                    self.localized(bundle: bundle)
                }
            
            }
            

            """
            
        }
        
        string += "// MARK: Strings\n\n"
        
        if let category = self.xcConfig.category {
            
            string += "public extension Twine /* \(self.inputFile.name) */ {\n\n"
            string += "    /// \(category) strings\n"
            string += "    struct \(category) {\n\n"
            
            for entry in entries {

                if let comment = entry.comment {
                    string += "        /// \"\(entry.key)\" - \(comment)\n"
                }
                else {
                    string += "        /// \"\(entry.key)\"\n"
                }

                string += "        public static let \(entry.formattedKey): LocalizedStringEntry = .init(key: \"\(entry.key)\")\n\n"

            }

            string += "    }\n\n"
            string += "}\n"
            
        }
        else {
            
            string += "public extension Twine /* \(self.inputFile.name) */ {\n\n"
            
            for entry in entries {

                if let comment = entry.comment {
                    string += "    /// \"\(entry.key)\" - \(comment)\n"
                }
                else {
                    string += "    /// \"\(entry.key)\"\n"
                }

                string += "    static let \(entry.formattedKey): LocalizedStringEntry = .init(key: \"\(entry.key)\")\n\n"

            }

            string += "}\n"
            
        }
        
        return string
        
    }
    
    private func log(_ message: String) {
        print(message.cyan)
    }
    
    private func error(_ message: String) {
        print("😢 \(message)".red)
    }
    
    private func error(_ error: XCTwineError) {
        self.error(error.description)
    }
    
}
