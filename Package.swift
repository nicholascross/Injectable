// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Injectable",
    products: [
        .library(name: "Injectable", targets: ["Injectable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/danger/swift.git", from: "1.0.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.35.8"),
        .package(url: "https://github.com/Realm/SwiftLint", from: "0.28.1"),
        .package(url: "https://github.com/orta/Komondor", from: "1.0.0"),
    ],
    targets: [
        .target(name: "Injectable", dependencies: [], path: "Injectable"),
        .testTarget(name: "InjectableTests", dependencies: ["Injectable"], path: "InjectableTests"),
    ]
)

#if canImport(PackageConfig)
    import PackageConfig

    let config = PackageConfig([
        "komondor": [
            // When someone has run `git commit`, first run
            // run SwiftFormat and the auto-correcter for SwiftLint
            // If there are any modifications then cancel the commit
            // so changes can be reviewed
            "pre-commit": [
                "git diff --cached --name-only | xargs git diff | md5 > .pre_format_hash",
                "swift run swiftformat .",
                "swift run swiftlint autocorrect --path Injectable/",
                "git diff --cached --name-only | xargs git diff | md5 > .post_format_hash",
                "diff .pre_format_hash .post_format_hash > /dev/null || { echo \"Staged files modified during commit\" ; rm .pre_format_hash ; rm .post_format_hash ; exit 1; }",
                "rm .pre_format_hash ; rm .post_format_hash",
            ],
        ],
    ])
#endif
