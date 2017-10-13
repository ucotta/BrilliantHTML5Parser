//
//  SearchableTree.swift
//  BrilliantHTML5Parser
//
//  Created by Ubaldo Cotta on 4/11/16.
//  Copyright © 2016 Ubaldo Cotta.
//
//  Licensed under Apache License v2.0
//

import Foundation


public protocol Node: class {
    weak var _parentNode: Node? { get set }
    var parentNode: Node? { get set }
    var root: Bool { get }
    var content: [Node] { get set }

    func indexOf(_ node: Node) -> Int?
    func setAfterNode(node: Node)
    func setBeforeNode(node: Node)
    func removeNode(node: Node)
    func addNode(node: Node)
    func putNode(node: Node, index: Int)
    // func destroyNodes() not necessary with weak var parentNode
}

extension Node {
    public func indexOf(_ node: Node) -> Int? {
        for (index, item) in content.enumerated() {
            if item === node {
                return index
            }
        }
        return nil
    }

    public var parentNode: Node? {
        set {
            removeFromParent()
            if newValue != nil {
                newValue?.addNode(node: self)
            }
        }
        get { return _parentNode }
    }

    private func removeFromParent() {
        if _parentNode != nil {
            _parentNode?.removeNode(node: self)
        }
    }

    public func removeNode(node: Node) {
        if let p:Int = indexOf(node) {
            node._parentNode = nil
            content.remove(at: p)
        }
    }

    public var root: Bool {
        get {
            return _parentNode == nil
        }
    }
    public func setAfterNode(node: Node) {
        if let p:Int = node.parentNode?.indexOf(node) {
            node.parentNode?.putNode(node: self, index: p + 1)
        } else {
            print("error setAfterNode, node not found in parent content. Using addNode")
            node.parentNode?.addNode(node: self)
        }
    }

    public func setBeforeNode(node: Node) {
        if let p:Int = node.parentNode?.indexOf(node) {
            node.parentNode?.putNode(node: self, index: p)
        } else {
            print("error setBeforeNode, node not found in parent content. Using addNode")
            node.parentNode?.addNode(node: self)
        }
    }

    public func addNode(node: Node) {
        // avoid call to parentNode because it add the Node too
        node.removeFromParent()
        node._parentNode = self
        content.append(node)
    }

    public func putNode(node: Node, index: Int) {
        // avoid call to parentNode because it add the Node too
        node.removeFromParent()
        node._parentNode = self
        content.insert(node, at: index)
    }

    func indexOf(node: Node) -> Int? {
        return content.index(where: { $0 === node })
    }
}

