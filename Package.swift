// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ssh-install",
    platforms: [.macOS(.v10_15)],
    products: [
        // executable to run directly, it used lib `SshInstall`
        .executable(name: "ssh-install", targets: ["ssh-install"]),
        // use lib inside other swift code
        .library(name: "SSHInstall", targets: ["SSHInstall"])
    ],
    dependencies: [
        .package(name: "ProcessPretty", url:"https://github.com/dooZdev/ProcessPretty.git", .upToNextMajor(from: "0.0.7")),
        .package(url: "https://github.com/dooZdev/UnifiedLogging.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .upToNextMajor(from: "0.2.2")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "0.3.0")),
    ],
    targets: [
        .target(name: "ssh-install", dependencies: ["SSHInstall"]),
        .target(
            name: "SSHInstall",
            dependencies: [
                .product(name: "UnifiedLogging", package: "UnifiedLogging"),
                .product(name: "ProcessPretty", package: "ProcessPretty"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
