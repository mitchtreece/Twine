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
    private var bundle: Bundle
    
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
    /// - parameter bundle: The bundle containing localized string assets.
    public init(wrappedValue: String,
                bundle: Bundle) {
        
        self.key = wrappedValue
        self.bundle = bundle
        
        update()
        
    }
    
    public init(wrappedValue: String) {
        
        self.init(
            wrappedValue: wrappedValue,
            bundle: .module
        )
        
    }
    
    // MARK: Private
    
    private mutating func update() {
        
        self.value = String(
            localized: .init(self.key),
            bundle: self.bundle
        )
        
        self._valuePublisher
            .send(self.value)
        
    }
    
}
