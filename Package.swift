// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Twine",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [

        .library(
            name: "Twine",
            targets: ["Twine"]
        ),

        .executable(
            name: "xctwine", 
            targets: ["xctwine"]
        ),

        .plugin(
            name: "XCTwinePlugin",
            targets: ["XCTwinePlugin"]
        )

    ],
    dependencies: [
        
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            .upToNextMajor(from: "1.0.0")
        ),
        
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            "600.0.0"..<"699.99.99"
        ),
        
        .package(
            url: "https://github.com/onevcat/Rainbow",
            .upToNextMajor(from: "4.0.0")
        )
        
	],
    targets: [

        .target(
            name: "Twine",
            dependencies: [
                .target(name: "TwineMacros")
            ],
            path: "Sources/Twine"
        ),
        
        .executableTarget(
            name: "xctwine",
            dependencies: [
                
				.product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
                
                .product(
                    name: "Rainbow",
                    package: "Rainbow"
                )
                
            ],
            path: "Sources/XCTwine"
        ),

        .plugin(
            name: "XCTwinePlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "xctwine")
            ],
            path: "Plugins/XCTwinePlugin"
        ),
        
        .macro(
            name: "TwineMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Sources/TwineMacros"
        )

    ]
)
