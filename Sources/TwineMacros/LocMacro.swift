//
//  LocMacro.swift
//  Twine
//
//  Created by Mitch on 2/10/25.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftCompilerPlugin

enum LocMacroError: Error {
    
    case invalidLocalizationKey
    
}

public struct LocMacro: ExpressionMacro {
    
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
                
        guard let localizationKey = node.arguments.first?.expression.description else {
            
            context.diagnose(Self.error(
                node,
                "Failed to parse localization key"
            ))
            
            throw LocMacroError.invalidLocalizationKey
            
        }
        
        let bundle = MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .identifier("Bundle")),
            period: .periodToken(),
            name: .identifier("module")
        )
        
        let arguments = LabeledExprListSyntax {
            
            LabeledExprSyntax(
                label: .identifier("localized"),
                colon: .colonToken(),
                expression: StringLiteralExprSyntax(
                    openingQuote: .stringQuoteToken(),
                    content: localizationKey,
                    closingQuote: .stringQuoteToken()
                ),
                trailingComma: .commaToken()
            )
            
//            LabeledExprSyntax(
//                label: .identifier("defaultValue"),
//                colon: .colonToken(),
//                expression: defaultValueLiteral,
//                trailingComma: .commaToken()
//            )
            
            LabeledExprSyntax(
                label: .identifier("bundle"),
                colon: .colonToken(),
                expression: bundle,
                trailingComma: nil
            )
            
        }
        
        let functionCall = FunctionCallExprSyntax(
            calledExpression: ExprSyntax(DeclReferenceExprSyntax(baseName: "String")),
            leftParen: .leftParenToken(),
            arguments: arguments,
            rightParen: .rightParenToken()
        )

        return ExprSyntax(functionCall)
        
    }
    
    // MARK: Private
    
    private static func error(_ node: FreestandingMacroExpansionSyntax,
                              _ message: String) -> Diagnostic {
        
        return .init(
            node: node,
            message: MacroExpansionErrorMessage(message)
        )
        
    }
    
}

@main
struct LocMacroPlugin: CompilerPlugin {
    
    var providingMacros: [any Macro.Type] {
        return [LocMacro.self]
    }
    
}
