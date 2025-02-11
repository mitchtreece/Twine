//
//  Config.swift
//  Twine
//
//  Created by Mitch on 2/10/25.
//

struct Config: Decodable {
    
    let namespace: String
    let keyFormat: KeyFormat
    let moduleExt: Bool
        
    static func from(file: File?,
                     namespace: String,
                     keyFormat: KeyFormat,
                     moduleExt: Bool) -> Self? {
        
        guard let file,
              let json = File.json(file),
              file.exists,
              (file.name == "xctwine" || file.name == "xctwine.json") else {
            
            return .init(
                namespace: namespace,
                keyFormat: keyFormat,
                moduleExt: moduleExt
            )
            
        }
        
        return .init(
            namespace: json["namespace"] as? String ?? namespace,
            keyFormat: KeyFormat(rawValue: (json["keyFormat"] as? String) ?? keyFormat.rawValue) ?? keyFormat,
            moduleExt: json["moduleExt"] as? Bool ?? moduleExt
        )
        
    }
    
}
