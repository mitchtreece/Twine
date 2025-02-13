//
//  Config.swift
//  Twine
//
//  Created by Mitch on 2/10/25.
//

struct Config: Decodable {
    
    let namespace: String
    let category: String?
    let format: KeyFormat
    let moduleExt: Bool
        
    static func from(file: File?,
                     namespace: String,
                     category: String?,
                     format: KeyFormat,
                     moduleExt: Bool) -> Self? {
        
        guard let file,
              let json = File.json(file),
              file.exists,
              (file.name == "xctwine" || file.name == "xctwine.json") else {
            
            return .init(
                namespace: namespace,
                category: category,
                format: format,
                moduleExt: moduleExt
            )
            
        }
        
        return .init(
            namespace: json["namespace"] as? String ?? namespace,
            category: json["category"] as? String ?? category,
            format: KeyFormat(rawValue: (json["format"] as? String) ?? format.rawValue) ?? format,
            moduleExt: json["moduleExt"] as? Bool ?? moduleExt
        )
        
    }
    
}
