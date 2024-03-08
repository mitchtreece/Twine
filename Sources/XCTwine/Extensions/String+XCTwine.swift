//
//  String+XCTwine.swift
//  XCTwine
//
//  Created by Mitch Treece on 3/8/24.
//

import Foundation

extension String {
    
    var words: [String] {
        
        return self
            .components(separatedBy: .alphanumerics.inverted)
            .filter { !$0.isEmpty }
        
    }
    
    var camelCased: String {
        
        guard !self.isEmpty else {
            return ""
        }
        
        let words = self.words
        
        let firstWord = words
            .first!
            .lowercased()
        
        let otherWords = words
            .dropFirst()
            .map { $0.capitalized }
        
        return ([firstWord] + otherWords).joined()
        
    }
    
    var pascalCased: String {
        
        return self.words
            .map { $0.capitalized }
            .joined()
        
    }
    
}
