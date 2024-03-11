// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "XCTwine",
    platforms: [.macOS(.v13)],
    products: [

        .executable(
            name: "xctwine", 
            targets: ["xctwine"]
        ),

        .plugin(
            name: "XCTwinePlugin",
            targets: ["XCTwinePlugin"]
        ),
        
        .library(
            name: "Localized",
            targets: ["Localized"]
        )

    ],
    dependencies: [
        
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            .upToNextMajor(from: "1.0.0")
        ),
        
        .package(
            url: "https://github.com/onevcat/Rainbow",
            .upToNextMajor(from: "4.0.0")
        )
        
	],
    targets: [
        
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
        
        .target(
            name: "Localized",
            path: "Sources/Localized"
        )

    ]
)
