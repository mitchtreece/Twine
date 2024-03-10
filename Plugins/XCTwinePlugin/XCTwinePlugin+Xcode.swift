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
        
        return try target
            .inputFiles
            .filter { $0.path.extension == "xcstrings" }
            .map { try .xctwine(file: $0, using: context) }
        
    }
    
}

#endif
