//
//  @Localized.swift
//  Twine
//
//  Created by Mitch Treece on 3/11/24.
//

import Foundation
import Combine

/// Localized string property-wrapper that replaces a
/// string-key value with a localized value.
@propertyWrapper
public struct Localized {
    
    private var entry: LocalizedStringEntry
    
    private let fallback: String?
    private let locale: Locale
    private let table: String?
    private var bundle: Bundle?
    
    /// A localized string value publisher.
    public var valuePublisher: AnyPublisher<String, Never> {
        return self._valuePublisher.eraseToAnyPublisher()
    }
    
    /// The wrapped localized value.
    public var wrappedValue: String {
        get {
            
            return self.entry.value(
                or: self.fallback,
                locale: self.locale,
                table: self.table,
                bundle: self.bundle
            )
            
        }
        set {
            
            self.entry = .init(
                key: newValue
            )
            
            publish()
            
        }
    }
    
    private let _valuePublisher = PassthroughSubject<String, Never>()
    
    /// Initializes the property-wrapper with a localized string key.
    /// - parameter wrappedValue: The localized string key.
    /// - parameter fallback: A fallback value to use if a localized value cannot be found.
    /// - parameter locale: The locale to use when localizing interpolated values.
    /// - parameter table: The bundle's string table to search.
    /// - parameter bundle: The bundle containing localized string assets.
    public init(wrappedValue: String,
                fallback: String? = nil,
                locale: Locale = .current,
                table: String? = nil,
                bundle: Bundle? = nil) {
        
        self.entry = .init(key: wrappedValue)
        
        self.fallback = fallback
        self.locale = locale
        self.table = table
        self.bundle = bundle
        
        publish()
        
    }
    
    /// Initializes the property-wrapper with a localized string entry.
    /// - parameter wrappedValue: The localized string entry.
    /// - parameter fallback: A fallback value to use if a localized value cannot be found.
    /// - parameter locale: The locale to use when localizing interpolated values.
    /// - parameter table: The bundle's string table to search.
    /// - parameter bundle: The bundle containing localized string assets.
    public init(wrappedValue: LocalizedStringEntry,
                fallback: String? = nil,
                locale: Locale = .current,
                table: String? = nil,
                bundle: Bundle? = nil) {
        
        self.init(
            wrappedValue: wrappedValue.key,
            fallback: fallback,
            locale: locale,
            table: table,
            bundle: bundle
        )
        
    }
    
    // MARK: Private
    
    private func publish() {
        
        self._valuePublisher
            .send(self.wrappedValue)
        
    }
    
}
