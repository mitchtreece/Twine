//
//  XCTwine.swift
//  XCTwine
//
//  Created by Mitch Treece on 3/8/24.
//

// xcstrings format:
//
//{
//  "sourceLanguage" : "en",
//  "strings" : {
//    "MY_STRING_KEY" : {
//      "comment" : "This is a really cool key",
//      "extractionState" : "manual",
//      "localizations" : {
//        "en" : {
//          "stringUnit" : {
//            "state" : "translated",
//            "value" : "My string value"
//          }
//        },
//        "es" : {
//          "stringUnit" : {
//            "state" : "translated",
//            "value" : "Mi valor de cadena"
//          }
//        }
//      }
//    }
//  },
//  "version" : "1.0"
//}

import Foundation
import ArgumentParser
import Rainbow

@main
struct XCTwine: ParsableCommand {
    
    @Argument(help: "The input xcstring file")
    private var inputFile: File
    
    @Argument(help: "The output string-extension file")
    private var outputFile: File
    
    @Option(
        name: .shortAndLong,
        help: "The output string-extension namespace"
    )
    private var namespace: String?
    
    @Option(
        name: [
            .customShort("f"),
            .customLong("format")
        ],
        help: "Output localization key format [none, camel, pascal]"
    )
    private var keyFormat: KeyFormat = .camel
    
    static let configuration = CommandConfiguration(
        commandName: "xctwine",
        abstract: "A Swift command-line tool for translating xcstring catalogue's into typed string extensions"
    )
    
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
        
        log("🧶 Translating \(self.inputFile.name.green.bold) → \(self.outputFile.name.green.bold)")
        
        if let namespace {
            log("📦 Using namespace: \(namespace.green)")
        }
        
        guard let inputFileJson = getJsonFromFile(self.inputFile) else {
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
                    format: self.keyFormat
                )
                
                let proposedKey = StringEntry.rawFormatKey(
                    key,
                    format: self.keyFormat
                )
                                
                return proposedKey == existingKey
                
            }
            .count
                        
            entries.append(StringEntry(
                key: key,
                format: self.keyFormat,
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
        
        var generateMessage = "📝 Creating \(self.outputFile.name.green.bold) extension file"
        
        switch self.keyFormat {
        case .none: generateMessage += " (unformatted)".yellow
        case .camel: generateMessage += " (camel-formatted)".yellow
        case .pascal: generateMessage += " (pascal-formatted)".yellow
        }
        
        log(generateMessage)
        
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
        
        log("🎉 Successfully generated \(self.outputFile.path.green.bold)")
        
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
        """
        
        string += "\n\n"
        
        if let namespace {
                        
            let namespaceType = "XCTwine_\(String(UUID().uuidString.prefix(4)))"

            string += "public extension StringProtocol where Self == String {"
            string += "\n\n"
            string += "    /// Localization namespace generated by XCTwine.\n"
            string += "    static var \(namespace): \(namespaceType) {\n"
            string += "        return \(namespaceType)()\n"
            string += "    }"
            string += "\n\n"
            string += "}"
            
            string += "\n\n"
            
            string += "/// Localization namespace type generated by XCTwine.\n"
            string += "public struct \(namespaceType) /* \(self.inputFile.name) */ {"
            string += "\n\n"
            
            for entry in entries {

                if let comment = entry.comment {
                    string += "    /// \(comment)\n"
                }

                string += "    public let \(entry.formattedKey): String = \"\(entry.key)\"\n\n"

            }
            
        }
        else {
            
            string += "public extension StringProtocol where Self == String /* \(self.inputFile.name) */ {"
            string += "\n\n"
            
            for entry in entries {
                
                if let comment = entry.comment {
                    string += "    /// \(comment)\n"
                }
                
                string += "    static let \(entry.formattedKey): String = \"\(entry.key)\"\n\n"
                
            }
            
        }
        
        string += "}\n"
        
        return string
        
    }
    
    private func getJsonFromFile(_ file: File) -> [String: Any]? {
        
        do {
            
            let data = try Data(contentsOf: file.pathUrl)
            
            let json = try JSONSerialization
                .jsonObject(with: data)
            
            return json as? [String: Any]
            
        }
        catch {
            return nil
        }
        
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
