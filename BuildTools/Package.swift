// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuildTools",
    dependencies: [
        .package(url: "https://github.com/doozMen/ssh-install.git", .upToNextMajor(from: "0.0.1"))
    ],
    targets: [
        .target(
            name: "build",
            dependencies: [.product(name: "SSHInstall", package: "ssh-install")]
        )
    ]
)
