//
//  String+Localized.swift
//  Twine
//
//  Created by Mitch on 2/10/25.
//

import Foundation

public extension String /* Localization */ {
    
    func localized(locale: Locale = .current,
                   table: String? = nil,
                   comment: StaticString? = nil,
                   in bundle: Bundle? = nil) -> String {
        
        return String(
            localized: .init(self),
            bundle: bundle,
            locale: locale,
            comment: comment
        )
        
    }
    
}
