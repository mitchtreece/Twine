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

        let config = target
            .inputFiles
            .first { file in
                
                return (
                    file.path.lastComponent == "xctwine" ||
                    file.path.lastComponent == "xctwine.json"
                )
                
            }
        
        return try target
            .inputFiles
            .filter { $0.path.extension == "xcstrings" }
            .map { file in
                
                try .xctwine(
                    file: file,
                    config: config,
                    context: context
                )
                
            }
        
    }
    
}

#endif
