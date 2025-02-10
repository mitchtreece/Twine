//
//  #Loc.swift
//  Twine
//
//  Created by Mitch on 2/10/25.
//

import Foundation

@freestanding(expression)
public macro loc(
    
    _ key: String
    
) = #externalMacro(
    
    module: "TwineMacros",
    type: "LocMacro"
    
)
