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
        
    private var key: String
    private var value: String!
    
    private let locale: Locale
    private let table: String?
    private let comment: StaticString?
    private var bundle: Bundle?
    
    /// A localized string value publisher.
    public var valuePublisher: AnyPublisher<String, Never> {
        return self._valuePublisher.eraseToAnyPublisher()
    }
    
    /// The wrapped localized value.
    public var wrappedValue: String {
        get { self.value }
        set {
            self.key = newValue
            update()
        }
    }
    
    private let _valuePublisher = PassthroughSubject<String, Never>()
    
    /// Initializes the property-wrapper with a localization string-key.
    /// - parameter wrappedValue: The localized string key.
    /// - parameter locale: The locale to use when localizing interpolated values.
    /// - parameter table: The bundle's string table to search.
    /// - parameter bundle: The bundle containing localized string assets.
    public init(wrappedValue: String,
                locale: Locale = .current,
                table: String? = nil,
                comment: StaticString? = nil,
                in bundle: Bundle? = nil) {
        
        self.key = wrappedValue
        
        self.locale = locale
        self.table = table
        self.comment = comment
        self.bundle = bundle
        
        update()
        
    }
    
    // MARK: Private
    
    private mutating func update() {
        
        self.value = String(
            localized: .init(self.key),
            table: self.table,
            bundle: self.bundle,
            locale: self.locale,
            comment: self.comment
        )
        
        self._valuePublisher
            .send(self.value)
        
    }
    
}
