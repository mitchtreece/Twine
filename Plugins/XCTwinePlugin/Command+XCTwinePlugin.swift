//
//  Command+XCTwinePlugin.swift
//  XCTwinePlugin
//
//  Created by Mitch Treece on 3/8/24.
//

import Foundation
import PackagePlugin

// MARK: Plugin Context

protocol PluginContextProtocol {
    
    var pluginWorkDirectory: Path { get }
    
    func tool(named name: String) throws -> PluginContext.Tool
    
}

private extension PluginContextProtocol {

    func outputPath(for file: File) -> Path {
        
        return self.pluginWorkDirectory
            .appending("\(file.path.stem)+XCTwine.swift")
        
    }
    
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
extension XcodePluginContext: PluginContextProtocol {}
#endif

extension PluginContext: PluginContextProtocol {}

// MARK: Command

extension Command {
    
    static func xctwine(file: File,
                        config: File?,
                        using context: PluginContextProtocol) throws -> Command {
        
        var args: [any CustomStringConvertible] = [
            file.path,
            context.outputPath(for: file)
        ]
        
        if let config {
            args.append("--config=\(config.path)")
        }
        
        return .buildCommand(
            displayName: "XCTwine: Generate string extensions for \(file.path.lastComponent)",
            executable: try context.tool(named: "xctwine").path,
            arguments: args,
            inputFiles: [file.path],
            outputFiles: [context.outputPath(for: file)]
        )
        
    }
    
}
