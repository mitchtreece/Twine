//
//  KeyFormat.swift
//  XCTwine
//
//  Created by Mitch Treece on 3/8/24.
//

import Foundation
import ArgumentParser

enum KeyFormat: String, ExpressibleByArgument {
    
    case none
    case camel
    case pascal
    
}
