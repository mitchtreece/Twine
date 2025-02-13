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
        
        // BaseApp/AppFeatures_AppFeature_Debug.bundle
        // appfeatures.AppFeature-Debug.resources
        
        let packageName = context.package.displayName.lowercased()
        let moduleName = sourceModule.moduleName.replacing("_", with: "-")
        let bundleId = "\(packageName).\(moduleName).resources"
                        
        return try sourceModule
            .sourceFiles(withSuffix: "xcstrings")
            .map { file in
                
                try Command.xctwine(
                    file: file,
                    bundle: bundleId,
                    config: config,
                    using: context
                )
                
            }
        
    }
    
}
