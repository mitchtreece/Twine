//
//  LocalizedStringEntry.swift
//  Twine
//
//  Created by Mitch on 2/11/25.
//

import Foundation

/// Localized string key / value representation.
public struct LocalizedStringEntry: ExpressibleByStringLiteral {
    
    /// The localized string key.
    public let key: String
    
    /// Initializes a localized string.
    /// - parameter key: The localized string key.
    public init(key: String) {
        self.key = key
    }
    
    /// Initializes a localized string from a literal.
    /// - parameter stringLiteral: The string literal.
    public init(stringLiteral value: StringLiteralType) {
        self.init(key: value)
    }
    
    /// Gets a localized string value.
    /// - parameter fallback: A fallback value to use if a localized value cannot be found.
    /// - parameter locale: The locale to use when localizing interpolated values.
    /// - parameter table: The bundle's string table to search.
    /// - parameter bundle: The bundle containing localized string assets.
    /// - returns: A localized string value.
    public func value(or fallback: String? = nil,
                      locale: Locale = .current,
                      table: String? = nil,
                      bundle: Bundle? = nil) -> String {
        
        let value = String(
            localized: .init(self.key),
            table: table,
            bundle: bundle,
            locale: locale
        )
        
        if let fallback, value == self.key {
            return fallback
        }
        
        return value
        
    }
    
}
