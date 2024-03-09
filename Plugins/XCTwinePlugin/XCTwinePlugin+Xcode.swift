//
//  XCTwinePlugin.swift
//  XCTwinePlugin
//
//  Created by Mitch Treece on 3/8/24.
//

#if canImport(XcodeProjectPlugin)

import PackagePlugin
import XcodeProjectPlugin

extension XCTwinePlugin: XcodeBuildToolPlugin {
    
    func createBuildCommands(context: XcodePluginContext, 
                             target: XcodeTarget) throws -> [Command] {
        
        let commands = try target
            .inputFiles
            .filter { $0.path.extension == "xcstrings" }
            .map { try Command.xctwine(file: $0, using: context) }
        
        guard !commands.isEmpty else {
            return []
        }
        
        return [commands.first!]
        
    }
    
}

#endif
