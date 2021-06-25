// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "NumberPicker",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "NumberPicker",
            targets: ["NumberPicker"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NumberPicker",
            dependencies: [],
            path: "NumberPicker"),
    ]
)
