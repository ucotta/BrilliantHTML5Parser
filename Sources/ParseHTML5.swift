//
//  ParseHTML5.swift
//  BrilliantHTML5Parser
//
//  Created by Ubaldo Cotta on 4/11/16.
//  Copyright © 2016 Ubaldo Cotta.
//
//  Licensed under Apache License v2.0
//

import Foundation

extension String {
    mutating func removePrefix(prefix: String) {
        if self == prefix {
            self = ""
        } else {
            removeSubrange(startIndex ... index(startIndex, offsetBy: prefix.characters.count-1))
        }
    }
}


enum ParseStep: Equatable {
    case preTag
    case tag
    case attributes
    case attributeValue
    case attributeValueSingle
    case attributeValueDouble
    case postTag
    case content
    case pre2Tag
    case tag2
    case post2tag
}

let DOCUMENT_DOESNT_START_WITH_DOCTYPE = "HTML Document doesnt start with correct HTML 5 DOCTYPE, add <!DOCTYPE html> at the begin of the document."

public class ParserHTML5 {
    public var root:HTMLNode  //= TagHTML(tagName: "")
    var html: String
    
    
    public func getNextNodeWithAtt(att: String) -> HTMLNode? {
        return root.getNextNodeWithAtt(att: att)
    }
    
    public func getNextAid() -> HTMLNode? {
        return root.getNextAid()
    }
    
    public func getNextTid() -> HTMLNode? {
        return root.getNextTid()
    }
    
    public func getNextJSid() -> HTMLNode? {
        return root.getNextJSid()
    }

    public func getAllBy(tagName: String) -> [HTMLNode] {
        return root.getAllBy(tagName: tagName)
    }

    
    public var toHTML: String {
        get {
            return root.toHTML
        }
    }

    public init(html _html:String) {
        self.html = _html
        if !html.hasPrefix(DocType.FULL_TAG) {
            root = TextHTML()
            root.rawHTML = DOCUMENT_DOESNT_START_WITH_DOCTYPE
        } else {
            root = DocType()
            html.removePrefix(prefix: DocType.FULL_TAG)
            while !html.isEmpty {
                root.addNode(node: startParsing())
            }
        }
    }
    public init() {
        self.html = ""
        root = DocType()
    }

    public func reparseNode(node: HTMLNode, html:String) {
        self.html = html
        let newNode = startParsing()
        
        newNode.setAfterNode(node: node)
        node.parentNode = nil
        self.html = ""
    }
    

    func startParsing() -> HTMLNode {
        var currentStep: ParseStep = .preTag
        var key: String = ""
        var value: String = ""

        let tag:HTMLNode = TextHTML()
        var content:HTMLNode? = nil

        while !html.isEmpty {
            if html.hasPrefix("<!--") {
                let comment = html.substring(to: html.range(of: "-->")!.upperBound)
                html = html.substring(from: html.range(of: "-->")!.upperBound)
                if tag.tagClass == .tag {
                    tag.addNode(node: CommentHTML(commentWithTag: comment))
                } else {
                    tag.rawHTML += comment
                }
                continue
            }
            if let c: Character = html.characters.popFirst() {
                switch c {
                        // PRE TAG
                case "<" where (currentStep == .preTag):
                    currentStep = .tag
                    tag.tagClass = .tag
                case _ where currentStep == .preTag:
                    tag.preTag.characters.append(c)

                        // TAG
                case " " where currentStep == .tag:
                    currentStep = .attributes
                    key = ""

                case ">" where currentStep == .tag:
                    currentStep = .content

                    if notClosingTags.contains(tag.tagName) {
                        return tag
                    }

                case "-" where currentStep == .tag  && tag.tagName == "<!-":
                    // Comment!!
                    tag.tagClass = .comment


                case _ where currentStep == .tag:
                    tag.tagName.characters.append(c)

                        // ATRIBUTO
                case "=" where currentStep == .attributes:
                    currentStep = .attributeValue
                    value = ""

                case ">" where currentStep == .attributes:
                    if !key.isEmpty {
                        tag["NO_VALUE_ATT=" + key] = key
                    }
                    currentStep = .content
                    if notClosingTags.contains(tag.tagName) {
                        return tag
                    }


                case _ where currentStep == .attributes:
                    key.characters.append(c)
                    if key == " " {
                        key = ""
                    }

                        // ATTRIBUTE VALUE
                case "\"" where currentStep == .attributeValue:
                    currentStep = .attributeValueDouble

                case "'" where currentStep == .attributeValue:
                    currentStep = .attributeValueSingle

                case "\"" where currentStep == .attributeValueDouble:
                    currentStep = .attributes
                    tag[key] = value
                    key = ""

                case "'" where currentStep == .attributeValueSingle:
                    currentStep = .attributes
                    tag[key] = value
                    key = ""

                case ">" where currentStep == .attributeValue:
                    if value.isEmpty {
                        tag["NO_VALUE_ATT=" + key] = key
                    } else {
                        tag[key] = value
                    }
                    key = ""
                    currentStep = .content
                    if notClosingTags.contains(tag.tagName) {
                        return tag
                    }


                case _ where currentStep == .attributeValue:
                    value.characters.append(c)

                case _ where currentStep == .attributeValueSingle:
                    value.characters.append(c)

                case _ where currentStep == .attributeValueDouble:
                    value.characters.append(c)

                    // CONTENT
                case "\n" where currentStep == .content:
                    if let node = content {
                        tag.addNode(node: node)
                    }
                    content = TextHTML(text: "\n")

                    //tag.addNode(node: content ?? TextHTML(text: "\n"))
                    //content = TextHTML()

                case "<" where (currentStep == .content && html.hasPrefix("/\(tag.tagName)>")):
                    if content != nil {
                        tag.addNode(node: content!)
                    }
                    html.removePrefix(prefix: "/\(tag.tagName)>")
                    return tag
                case "<" where currentStep == .content:
                    if let node = content {
                        // Put back the extracted HTML.
                        // Beware of it, when start with \n<tag this will fail
                        //node.rawHTML.characters.insert(c, at: node.rawHTML.characters.startIndex)
                        node.rawHTML.append(c)
                        html = node.rawHTML + html
                        content = nil
                    } else {
                        html.characters.insert(c, at: html.characters.startIndex)
                    }
                    tag.addNode(node: startParsing())

                case _ where currentStep == .content:
                    if content == nil {
                        content = TextHTML()
                    }
                    content!.rawHTML.characters.append(c)

                default:
                    print("You don't exist, go away!")


                }
            }

        }
        return tag
    }
}
