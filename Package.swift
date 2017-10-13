// swift-tools-version:4.0
//
//  Package.swift
//  BrilliantHTML5Parser
//
//  Created by Ubaldo Cotta on 7/11/16.
//  Copyright © 2016 Ubaldo Cotta.
//
//  Licensed under Apache License v2.0
//

import PackageDescription

let package = Package(
    name: "BrilliantHTML5Parser",
    products: [
		.library(
			name: "BrilliantHTML5Parser",
			targets: ["BrilliantHTML5Parser"]),
	],
    dependencies: [
		.package(url: "https://github.com/IBM-Swift/swift-html-entities.git", .upToNextMajor(from: "3.0.0"))
    ],
	targets: [
		// Targets are the basic building blocks of a package. A target defines a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages which this package depends on.
		.target(
			name: "BrilliantHTML5Parser",
			dependencies: ["HTMLEntities"]),
		.testTarget(
			name: "BrilliantHTML5ParserTests",
			dependencies: ["BrilliantHTML5Parser", "HTMLEntities"]),
		]
)

