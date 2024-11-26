// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "CPFCNPJTools",
    products: [
        .library(
            name: "CPFCNPJTools",
            targets: ["CPFCNPJTools"]
        ),
    ],
    targets: [
        .target(
            name: "CPFCNPJTools",
            path: "CPFCNPJTools/Source"
        ),
        .testTarget(
            name: "CPFCNPJTools-Unit-Tests",
            dependencies: ["CPFCNPJTools"],
            path: "CPFCNPJTools/Tests"
        ),
    ]
)
