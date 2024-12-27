// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LDXImagePicker",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LDXImagePicker",
            type: .dynamic,
            targets: ["LDXImagePicker"])
    ],
    targets: [
        .target(
            name: "LDXImagePicker",
            path: "LDXImagePicker",
            exclude: ["Info.plist"],
            resources: [
                .process("Assets.xcassets"),
                .copy("en.lproj"),
                .copy("zh-Hans.lproj"),
                .copy("pl.lproj"),
                .copy("de.lproj"),
                .copy("es.lproj"),
                .copy("ja.lproj")
            ],
            publicHeadersPath: "."
        )
    ]
)
