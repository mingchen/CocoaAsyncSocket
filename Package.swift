// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CocoaAsyncSocket",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "CocoaAsyncSocket",
            targets: ["CocoaAsyncSocket"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CocoaAsyncSocket",
            dependencies: [],
            path: "Source/GCD",
            publicHeadersPath: ""),

        .testTarget(name: "SharedObjCTests",
                    dependencies: ["CocoaAsyncSocket"],
                    path: "Tests/Shared/ObjC"),

        .testTarget(name: "SharedSwiftTests",
                    dependencies: ["CocoaAsyncSocket"],
                    path: "Tests/Shared/Swift")
    ]
)
