//
//  XCTwineError.swift
//  XCTwine
//
//  Created by Mitch Treece on 3/8/24.
//

import Foundation

enum XCTwineError: Error, CustomStringConvertible {
    
    case inputFileNotFound
    case inputFileInvalidExtension
    case inputFileJsonSerialization
    case inputFileInvalidJson
    case outputFileInvalidExtension
    case outputDataInvalid
    case outputFileFailedToWrite
    
    var description: String {
        
        switch self {
        case .inputFileNotFound: "Input file not found"
        case .inputFileInvalidExtension: "Invalid input file extension, must be \".xcstrings\""
        case .inputFileJsonSerialization: "Failed to serialize input file into json"
        case .inputFileInvalidJson: "Invalid input file json"
        case .outputFileInvalidExtension: "Invalid output file extension, must be \".swift\""
        case .outputDataInvalid: "Invalid output data"
        case .outputFileFailedToWrite: "Failed to write to output file"
        }
        
    }

}
