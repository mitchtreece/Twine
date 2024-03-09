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
        
        let commands = try sourceModule
            .sourceFiles(withSuffix: "xcstrings")
            .map { try Command.xctwine(file: $0, using: context) }
        
        guard !commands.isEmpty else {
            return []
        }
        
        return [commands.first!]
        
    }
    
}
