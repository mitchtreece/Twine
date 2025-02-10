//
//  StringEntry.swift
//  XCTwine
//
//  Created by Mitch Treece on 3/8/24.
//

import Foundation

struct StringEntry {
    
    let key: String
    let formattedKey: String
    let comment: String?
    let duplicateIndex: UInt?
    
    init(key: String,
         format: KeyFormat,
         comment: String?,
         duplicateIndex: UInt?) {
        
        self.key = key
        
        self.formattedKey = Self.formatKey(
            key,
            format: format,
            duplicateIndex: duplicateIndex
        )
        
        self.comment = comment
        self.duplicateIndex = duplicateIndex
        
    }
    
    static func rawFormatKey(_ key: String,
                             format: KeyFormat) -> String {
                
        return switch format {
        case .none: key
        case .camel: key.camelCased
        case .pascal: key.pascalCased
        }
        
    }
        
    static func formatKey(_ key: String,
                          format: KeyFormat,
                          duplicateIndex: UInt?) -> String {
        
        var raw = rawFormatKey(
            key,
            format: format
        )
        
        if let duplicateIndex {
            raw += "\(duplicateIndex)"
        }
        
        return raw
        
    }
    
}
