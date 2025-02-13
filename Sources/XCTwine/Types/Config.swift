//
//  Config.swift
//  Twine
//
//  Created by Mitch on 2/10/25.
//

struct Config: Decodable {
    
    let namespace: String?
    let format: KeyFormat
    let moduleExt: Bool
    let publicAccess: Bool
        
    static func from(file: File?,
                     namespace: String?,
                     format: KeyFormat,
                     moduleExt: Bool,
                     publicAccess: Bool) -> Self? {
        
        guard let file,
              let json = File.json(file),
              file.exists,
              (file.name == "xctwine" || file.name == "xctwine.json") else {
            
            return .init(
                namespace: namespace,
                format: format,
                moduleExt: moduleExt,
                publicAccess: publicAccess
            )
            
        }
        
        return .init(
            namespace: json["namespace"] as? String ?? namespace,
            format: KeyFormat(rawValue: (json["format"] as? String) ?? format.rawValue) ?? format,
            moduleExt: json["moduleExt"] as? Bool ?? moduleExt,
            publicAccess: json["public"] as? Bool ?? publicAccess
        )
        
    }
    
}
