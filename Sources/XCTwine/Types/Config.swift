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
        
    static func from(file: File?,
                     namespace: String?,
                     keyFormat: KeyFormat,
                     generateBundleExtensions: Bool) -> Self? {
        
        guard let file,
              let json = File.json(file),
              file.exists,
              (file.name == "xctwine" || file.name == "xctwine.json") else {
            
            return .init(
                namespace: namespace,
                keyFormat: keyFormat,
                generateBundleExtensions: generateBundleExtensions
            )
            
        }
        
        return .init(
            namespace: json["namespace"] as? String ?? namespace,
            keyFormat: KeyFormat(rawValue: (json["keyFormat"] as? String) ?? keyFormat.rawValue) ?? keyFormat,
            generateBundleExtensions: json["bundleExt"] as? Bool ?? generateBundleExtensions
        )
        
    }
    
}
