// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Twine",
    platforms: [.macOS(.v13)],
    products: [

        .library(
            name: "Twine",
            targets: ["Twine"]
        ),

        .executable(
            name: "xctwine", 
            targets: ["XCTwine"]
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
            url: "https://github.com/onevcat/Rainbow",
            .upToNextMajor(from: "4.0.0")
        )
        
	],
    targets: [

        .target(
            name: "Twine",
            path: "Sources/Twine"
        ),
        
        .executableTarget(
            name: "XCTwine",
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
                .target(name: "XCTwine")
            ],
            path: "Plugins/XCTwinePlugin"
        )

    ]
)
