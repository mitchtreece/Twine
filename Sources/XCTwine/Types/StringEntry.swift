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
    
    init(key: String,
         format: KeyFormat,
         comment: String?) {
        
        self.key = key
        
        switch format {
        case .none: self.formattedKey = key
        case .camel: self.formattedKey = key.camelCased
        case .pascal: self.formattedKey = key.pascalCased
        }
        
        self.comment = comment
        
    }
    
}
