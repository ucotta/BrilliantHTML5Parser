//
//  HTMLEntity.swift
//  BrilliantHTML5Parser
//
//  Created by Ubaldo Cotta on 7/11/16.
//  Copyright © 2016 Ubaldo Cotta.
//
//  Licensed under Apache License v2.0
//

import Foundation

public enum TagClass { case tag, text, comment, docType, noDefined}

let notClosingTags: [String] = "!DOCTYPE area base br col embed hr img input keygen link meta param source track wbr".components(separatedBy: " ")

extension Node {
    public var toHTML: String { get { return "" } }
    public var innerHTML: String { get { return "" } }
}

public class HTMLNode: Node {
    weak public var _parentNode: Node? = nil
    public var rawHTML: String = ""
    public var tagClass: TagClass  = .noDefined
    public var preTag: String = ""
    public var posTag: String = ""
    public var tagName: String = ""
    public var prefixClass: String? = nil
    public var prefixAttribute: String = ""

    var _attributes: [String:String] = [:]

    public var content: [Node] = []

    static var totalNodes = 0

    public var whoAmI: String {
        get {
            if let parent = _parentNode as! HTMLNode? {
                return parent.whoAmI + ">\(tagClass):\(tagName)"
            }
            return ">\(tagClass):\(tagName)"
        }
    }

    public func removeNodes() {
        content.removeAll()
    }

    public func copyNode() -> HTMLNode {
        let newNode = HTMLNode()
        newNode.rawHTML = rawHTML
        newNode.tagClass = tagClass
        newNode.preTag = preTag
        newNode.posTag = posTag
        newNode.tagName = tagName
        for i in 0..<content.count {
            let newContent: HTMLNode = content[i] as! HTMLNode
            newContent.copyNode().parentNode = newNode
        }

        //newNode.content = content
        for key in _attributes.keys {
            newNode[key] = self[key]
        }

        //newNode.setBeforeNode(node: self)
        return newNode
    }

    public init() {
        //super.init()
        HTMLNode.totalNodes += 1
        //print("init, nodes \(HTMLNode.totalNodes)")
    }
    deinit {
        HTMLNode.totalNodes -= 1
        //print("deinit, nodes \(HTMLNode.totalNodes)")
    }

    public subscript(key: String) -> String? {
        get { return _attributes[key] }
        set(value) { _attributes[key] = value }
    }

    public func findAttributeWithPrefix(_ prefix:String) -> (key: String, value: String)? {
        let items = _attributes.filter {
            key, value in
            return key.hasPrefix(prefix)
        }
        if items.count == 0 {
            return nil
        }

        var key: String  = items[0].0
        prefixClass = key
        prefixAttribute = key
        prefixAttribute.removePrefix(prefix + "-")

        key.removePrefix(prefix)

        return (key: key, value: items[0].1)
    }


    public func getNextNodeWithAtt(att: String) -> HTMLNode? {
        for node in content {
            if let n:HTMLNode = node as? HTMLNode {
                if n[att] != nil {
                    return n
                }
                if let n2 = n.getNextNodeWithAtt(att: att) {
                    return n2
                }
            }
        }

        return nil
    }


    public func getNextNodeWithAtt(prefix: String) -> HTMLNode? {
        for node in content {
            if let n:HTMLNode = node as? HTMLNode {
                if n.findAttributeWithPrefix(prefix) != nil {
                    return n
                }
                if let n2 = n.getNextNodeWithAtt(prefix: prefix) {
                    return n2
                }
            }
        }

        return nil
    }


    public func getNextBid() -> HTMLNode? {
        return getNextNodeWithAtt(prefix: "bid")
    }

    public func getNextTid() -> HTMLNode? {
        return getNextNodeWithAtt(att: "tid")
    }

    public func getNextJSid() -> HTMLNode? {
        return getNextNodeWithAtt(att: "jsid")
    }
    
    public func getAllBy(tagName: String) -> [HTMLNode] {
        var nodes: [HTMLNode] = []
        
        if self.tagName == tagName {
            nodes.append(self)
        }
        
        for item in self.content {
            if item is HTMLNode {
                let node:HTMLNode = item as! HTMLNode
                nodes += node.getAllBy(tagName: tagName)
            }
        }
        
        return nodes
    }
    

    public func replaceBy(string: String) {
        content.removeAll()
        rawHTML = string
        tagClass = .text
    }

    public func replaceContentBy(string: String) {
        content.removeAll()
        content.append(TextHTML(text: string))
    }


    public var toHTML: String {
        get {
            switch tagClass {
            case .comment, .text, .noDefined:
                return preTag + rawHTML + posTag
            default:
                var html = preTag
                html += "<\(tagName)"

                for key in _attributes.keys {
                    if key.hasPrefix("NO_VALUE_ATT=") {
                        html += " \(self[key]!)"
                    } else {
                        html += " \(key)=\"\(self[key]!)\""
                    }
                }

                html += ">"

                for node in content {
                    if let n:HTMLNode = node as? HTMLNode {
                        html += n.toHTML
                    }

                }

                if !notClosingTags.contains(tagName) {
                    html += "</\(tagName)>"
                }
                html += posTag

                return html
            }
        }
    }

    
    
    public var innerHTML: String {
        get {
            switch tagClass {
            case .comment, .text, .noDefined:
                return preTag + rawHTML + posTag
            default:
                var html = ""
                for node in content {
                    if let n:HTMLNode = node as? HTMLNode {
                        html += n.toHTML
                    }
                    
                }
                
                return html
            }
        }
    }
    


    public var debug: String {
        get {
            switch tagClass {
            case .comment:
                return "<COMMENT>"
            case .text, .noDefined:
                return "TEXT"
            default:
                var html = preTag
                html += "<\(tagName.uppercased())"

                for key in _attributes.keys {
                    if key.hasPrefix("NO_VALUE_ATT=") {
                        html += " \(self[key]!.uppercased())"
                    } else {
                        html += " \(key.uppercased())=\"\(self[key]!)\""
                    }
                }

                html += ">"

                for node in content {
                    if let n:HTMLNode = node as? HTMLNode {
                        html += n.debug
                    }

                }

                if !notClosingTags.contains(tagName) {
                    html += "</\(tagName.uppercased())>"
                }
                html += posTag

                return html
            }
        }
    }

}

public class DocType: HTMLNode {
    static let FULL_TAG = "<!DOCTYPE html>"
    override public init() {
        super.init()
        tagClass = .docType
        tagName = "!DOCTYPE"
        self["NO_VALUE_ATT=html"] = "html"
    }
}

public class TextHTML: HTMLNode {
    public init(text: String) {
        super.init()
        rawHTML = text
        tagClass = .text
    }
    override public init() {
        super.init()
        tagClass = .text
    }
}

public class CommentHTML: HTMLNode {
    public init(comment: String) {
        super.init()
        
        rawHTML = "<!--\(comment)-->"
        tagClass = .comment
    }
    public init(commentWithTag: String) {
        super.init()
        rawHTML = commentWithTag
        tagClass = .comment
    }
    override public init() {
        super.init()
        tagClass = .comment
    }
}

public class TagHTML: HTMLNode {
    override public init() {
        super.init()
        tagClass = .tag
    }
    public init(tagName tag:String) {
        super.init()
        tagClass = .tag
        tagName = tag
    }
    public init(tagName tag:String, content:String) {
        super.init()
        tagClass = .tag
        tagName = tag
        addNode(node: TextHTML(text: content))
    }

}

