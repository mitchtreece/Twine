//
//  String+Localized.swift
//  Twine
//
//  Created by Mitch on 2/10/25.
//

import Foundation

public extension String /* Localization */ {
    
    /// Gets a localized string entry using the receiver as a key.
    /// - returns: A localized string entry.
    func asLocalizedStringEntry() -> LocalizedStringEntry {
        return .init(key: self)
    }
    
    /// Gets a localized string value using the receiver as a key.
    /// - parameter fallback: A fallback value to use if a localized value cannot be found.
    /// - parameter locale: The locale to use when localizing interpolated values.
    /// - parameter table: The bundle's string table to search.
    /// - parameter bundle: The bundle containing localized string assets.
    /// - returns: A localized string value.
    func localized(or fallback: String? = nil,
                   locale: Locale = .current,
                   table: String? = nil,
                   bundle: Bundle? = nil) -> String {
        
        return asLocalizedStringEntry().value(
            or: fallback,
            locale: locale,
            table: table,
            bundle: bundle
        )
        
    }
    
}
