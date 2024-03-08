//
//  File.swift
//  XCTwine
//
//  Created by Mitch Treece on 3/8/24.
//

import Foundation
import ArgumentParser

struct File: ExpressibleByArgument {
    
    let path: String
    
    var pathUrl: URL {
        return .init(filePath: self.path)
    }
    
    var filename: String {
        
        return self.pathUrl
            .lastPathComponent
        
    }
    
    var `extension`: String? {
        
        let components = self.path
            .components(separatedBy: "/")
        
        guard !components.isEmpty else {
            return nil
        }
                
        return components
            .last!
            .components(separatedBy: ".")
            .last
        
    }
    
    var exists: Bool {
        
        return self.fileManager
            .fileExists(atPath: self.path)
        
    }
    
    private let fileManager = FileManager.default
    
    init?(argument: String) {
        self.path = argument
    }
    
}
