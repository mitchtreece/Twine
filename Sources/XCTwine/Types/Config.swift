//
//  Config.swift
//  Twine
//
//  Created by Mitch on 2/10/25.
//

struct Config: Decodable {
    
    let namespace: String?
    let keyFormat: KeyFormat
    let generateBundleExtensions: Bool
        
    static func from(file: File,
                     namespace: String?,
                     keyFormat: KeyFormat,
                     generateBundleExtensions: Bool) -> Self {
        
        guard let json = File.json(file),
              let args = json["args"] as? [String: Any] else {
            
            return .init(
                namespace: namespace,
                keyFormat: keyFormat,
                generateBundleExtensions: generateBundleExtensions
            )
            
        }
        
        return .init(
            namespace: args["namespace"] as? String ?? namespace,
            keyFormat: KeyFormat(rawValue: (args["keyFormat"] as? String) ?? keyFormat.rawValue) ?? keyFormat,
            generateBundleExtensions: args["bundle-ext"] as? Bool ?? generateBundleExtensions
        )
        
    }
        
}
