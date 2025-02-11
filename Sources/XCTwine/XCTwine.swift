//
//  XCTwine.swift
//  XCTwine
//
//  Created by Mitch Treece on 3/8/24.
//

import Foundation
import ArgumentParser
import Rainbow

@main
struct XCTwine: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "xctwine",
        abstract: "A Swift command-line tool for translating xcstring catalogue's into typed string extensions"
    )
    
    @Argument(help: "The input xcstring file")
    private var inputFile: File
    
    @Argument(help: "The output string-extension file")
    private var outputFile: File
    
    @Option(
        name: [
            .customShort("c"),
            .customLong("config")
        ],
        help: "Optional configuration file to use"
    )
    private var configFile: File?
    
    @Option(
        name: .shortAndLong,
        help: "The output string-extension namespace"
    )
    private var namespace: String = "Twine"
    
    @Option(
        name: [
            .customShort("f"),
            .customLong("format")
        ],
        help: "Output localization key format [none, camel, pascal]"
    )
    private var keyFormat: KeyFormat = .camel
    
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
            namespace: self.namespace,
            keyFormat: self.keyFormat,
            moduleExt: self.moduleExt
        )
        
        if let configFile {
            log("⚙️ Using config file \(configFile.path.green)")
        }
        else {
            log("⚙️ Using config arguments")
        }
        
        log("   ﹂namespace: \(self.xcConfig.namespace.green)")
        log("   ﹂keyFormat: \(self.xcConfig.keyFormat.rawValue.green)")
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
                    format: self.xcConfig.keyFormat
                )
                
                let proposedKey = StringEntry.rawFormatKey(
                    key,
                    format: self.xcConfig.keyFormat
                )
                                
                return proposedKey == existingKey
                
            }
            .count
                        
            entries.append(StringEntry(
                key: key,
                format: self.xcConfig.keyFormat,
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
        
        import Twine
        
        
        """
        
        if self.xcConfig.moduleExt {
            
            string += """
            public extension LocalizedStringEntry /* Module */ {
            
                /// Gets a localized string value in the current module.
                var value: String {
                    self.value(bundle: .module)
                }
            
            }
            
            public extension Localized /* Module */ {
            
                /// Initializes the property-wrapper with a localized
                /// string key in the current module.
                init(wrappedValue: String) {
                    
                    self.init(
                        wrappedValue: wrappedValue,
                        bundle: .module
                    )
            
                }
            
            }
            
            public extension String /* Module */ {
            
                /// Gets a localized string value in the current module.
                var localized: String {
                    self.localized(bundle: .module)
                }
            
            }
            
            
            """
            
        }
        
        string += "public struct \(self.xcConfig.namespace) /* \(self.inputFile.name) */ {\n\n"
        string += "    private init() {}\n\n"
        
        for entry in entries {
            
            if let comment = entry.comment {
                string += "    /// \"\(entry.key)\": \(comment)\n"
            }
            else {
                string += "    /// \"\(entry.key)\"\n"
            }
  
            string += "    public static let \(entry.formattedKey): LocalizedStringEntry = .init(key: \"\(entry.key)\")\n\n"
                      
        }
        
        string += "}\n"
        
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
