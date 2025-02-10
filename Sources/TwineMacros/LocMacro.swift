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
    
    public static func expansion(of node: some FreestandingMacroExpansionSyntax,
                                 in context: some MacroExpansionContext) throws -> ExprSyntax {
                
        guard let locKeyExpression = node.arguments.first?.expression.as(StringLiteralExprSyntax.self) else {
            
            context.diagnose(Self.error(
                node,
                "Failed to parse localization key"
            ))
            
            throw LocMacroError.invalidLocalizationKey
            
        }
        
        var bundleExpression: StringLiteralExprSyntax?
        
        if node.arguments.count > 1 {
            
            bundleExpression = node
                .arguments
                .last?
                .expression
                .as(StringLiteralExprSyntax.self)
            
        }
        
        let fnArgs = LabeledExprListSyntax {
            
            LabeledExprSyntax(
                label: "localized",
                expression: locKeyExpression,
                trailingComma: (bundleExpression != nil) ? .commaToken() : nil
            )
            
            if let bundleExpression {
                
                LabeledExprSyntax(
                    label: "bundle",
                    expression: bundleExpression
                )
                
            }
        
        }
        
        return ExprSyntax(FunctionCallExprSyntax(
            calledExpression: DeclReferenceExprSyntax(baseName: "String"),
            leftParen: .leftParenToken(),
            arguments: fnArgs,
            rightParen: .rightParenToken()
        ))
        
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
