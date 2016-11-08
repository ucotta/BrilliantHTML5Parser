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
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/swift-html-entities.git", majorVersion: 2, minor: 0)
    ],
    exclude: ["BrilliantHTML5ParserTest", "examples"]
)
