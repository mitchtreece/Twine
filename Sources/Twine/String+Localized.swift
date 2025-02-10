//
//  String+Localized.swift
//  Twine
//
//  Created by Mitch on 2/10/25.
//

import Foundation

public extension String /* Localization */ {
    
    var localized: String {
        return localized(in: nil)
    }
    
    func localized(in bundle: Bundle? = nil) -> String {
        
        return String(
            localized: .init(self),
            bundle: bundle
        )
        
    }
    
}
