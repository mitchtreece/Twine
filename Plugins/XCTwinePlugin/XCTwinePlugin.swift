//
//  XCTwinePlugin.swift
//  XCTwinePlugin
//
//  Created by Mitch Treece on 3/8/24.
//

import Foundation
import PackagePlugin

@main
struct XCTwinePlugin: BuildToolPlugin {
    
    func createBuildCommands(context: PluginContext, 
                             target: Target) async throws -> [Command] {
                
        guard let sourceModule = target.sourceModule else {
            Diagnostics.warning("XCTwinePlugin does not support non-source targets")
            return []
        }
                        
        let config = sourceModule
            .sourceFiles
            .first { file in
                
                return (
                    file.path.lastComponent == "xctwine" ||
                    file.path.lastComponent == "xctwine.json"
                )
                
            }
        
        return try sourceModule
            .sourceFiles(withSuffix: "xcstrings")
            .map { file in
                
                try Command.xctwine(
                    file: file,
                    config: config,
                    context: context
                )
                
            }
        
    }
    
}
