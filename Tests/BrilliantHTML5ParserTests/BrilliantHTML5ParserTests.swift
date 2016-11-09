//
//  BrilliantHTML5ParserTest.swift
//  BrilliantHTML5ParserTest
//
//  Created by Ubaldo Cotta on 7/11/16.
//  Copyright © 2016 Ubaldo Cotta.
//
//  Licensed under Apache License v2.0
//



import XCTest
@testable import BrilliantHTML5Parser


class BrilliantHTML5ParserTest: XCTestCase {
    var _pathTemplates: String? = nil
    
    override func setUp() {
        super.setUp()
        
        var parts = #file.components(separatedBy: "/")
        parts.removeLast()
        parts.append("Templates")
        _pathTemplates = parts.map { String($0) }.joined(separator: "/")
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func getPathTemplates() -> String {
        return _pathTemplates ?? ""
    }
    
    func test1_DOCTYPE() {
        var parser = ParserHTML5(html: "<!DOCTYPE html>")
        XCTAssertEqual(parser.toHTML, "<!DOCTYPE html>", "Incorrect toHTML !DOCTYPE result")
        XCTAssertEqual(parser.root.toHTML, "<!DOCTYPE html>", "Incorrect toHTML !DOCTYPE result")
        
        parser = ParserHTML5(html: "<!DOC1TYPE html>")
        XCTAssertEqual(parser.toHTML, DOCUMENT_DOESNT_START_WITH_DOCTYPE, "Wrong DOCTYPE doesnt cause error!")
    }
    
    func _createBasicHTML() -> ParserHTML5 {
        let parser = ParserHTML5()
        
        let html = TagHTML(tagName: "html")
        let head = TagHTML(tagName: "head")
        let body = TagHTML(tagName: "body")
        let div = TagHTML(tagName: "div")
        div["dupl"] = "3"
        
        html["lang"] = "en"
        head.addNode(node: TagHTML(tagName: "title", content: "Welcome title!!"))
        body.addNode(node: TagHTML(tagName: "h1", content: "Welcome!"))
        body.addNode(node: div)
        
        
        // Add nodes
        html.addNode(node: head)
        html.addNode(node: body)
        parser.root.addNode(node: html)
        return parser
    }
    
    
    func test2_createHTML() {
        let RESULT_CREATE = "<!DOCTYPE html><html lang=\"en\"><head><title>Welcome title!!</title></head><body><h1>Welcome!</h1><div dupl=\"3\"></div></body></html>"
        
        do {
            let parser = _createBasicHTML()
            XCTAssertEqual(parser.toHTML, RESULT_CREATE)
            let parser2 = ParserHTML5(html: parser.toHTML)
            XCTAssertEqual(parser2.toHTML, RESULT_CREATE)
            //parser.root.removeNodes()
            //parser2.root.removeNodes()
        }
        XCTAssertEqual(HTMLNode.totalNodes, 0, "Error leak of nodes!!")
        
    }
    
    func test3_createHTMLduplicate() {
        let RESULT_TEST = "<!DOCTYPE html><html lang=\"en\"><head><title>Welcome title!!</title></head><body><h1>Welcome!</h1><div>This is the 1 div</div><div>This is the 2 div</div><div>This is the 3 div</div><!--Here was the original DIV--></body></html>"
        
        do {
            let parser = _createBasicHTML()
            if let div = parser.root.getNextNodeWithAtt(att: "dupl") {
                for i in 1...3 {
                    let new = div.copyNode()
                    new["dupl"] = nil
                    new.addNode(node: TextHTML(text: "This is the \(i) div"))
                    new.setBeforeNode(node: div)
                }
                div.replaceBy(string: CommentHTML(comment: "Here was the original DIV").toHTML)
                
                XCTAssertEqual(parser.toHTML, RESULT_TEST, "Error result duplicate node!")
            } else {
                XCTFail("getNodeWithAtt failed")
            }
        }
        XCTAssertEqual(HTMLNode.totalNodes, 0, "Error leak of nodes!!")
    }
    
    func test4_comentaries() {
        let RESULT_TEST = "<!DOCTYPE html><html lang=\"en\"><head><title>Welcome title!!</title></head><body><h1>Welcome!</h1><!--<div dupl=\"3\"></div>--></body></html>"
        
        do {
            let parser = _createBasicHTML()
            if let div = parser.root.getNextNodeWithAtt(att: "dupl") {
                // first comment the div with att dupl=3
                div.parentNode?.addNode(node: CommentHTML(comment: div.toHTML))
                // Delete the node.
                div.parentNode = nil
                
                XCTAssertEqual(parser.toHTML, RESULT_TEST, "Error result commenting a div")
                
                // must not be find.
                XCTAssertNil(parser.root.getNextNodeWithAtt(att: "dupl"), "Error parser, get div in inside comment")
                
                // Now reparse again
                let parser2 = ParserHTML5(html: parser.toHTML)
                
                XCTAssertEqual(parser2.toHTML, RESULT_TEST, "Error reparsing with comment")
                XCTAssertNil(parser2.root.getNextNodeWithAtt(att: "dupl"), "Error parser, get div in inside comment")
            } else {
                XCTFail("getNodeWithAtt failed")
            }
        }
        XCTAssertEqual(HTMLNode.totalNodes, 0, "Error leak of nodes!!")
    }
    
    func test5_getAllByTagName() {
        do {
            let parser = _createBasicHTML()
            var divs = parser.getAllBy(tagName: "div")
            
            XCTAssertEqual(divs.count, 1)
            XCTAssertEqual(divs.popLast()?.tagName, "div")
        }
        XCTAssertEqual(HTMLNode.totalNodes, 0, "Error leak of nodes!!")
    }
    
    func test6_reparseNode() {
        let RESULT_TEST = "<!DOCTYPE html><html lang=\"en\"><head><title>Welcome title!!</title></head><body><h1>Welcome!</h1><b>replaced node!</b></body></html>"

        do {
            let parser = _createBasicHTML()
            if let div = parser.root.getNextNodeWithAtt(att: "dupl") {
                parser.reparseNode(node: div, html: "<b>replaced node!</b>")
                XCTAssertEqual(parser.toHTML, RESULT_TEST, "Error in reparseNode")
            } else {
                XCTFail("reparseNode no realiced because error in getNextNodeWitAtt")
                
            }
        }
        XCTAssertEqual(HTMLNode.totalNodes, 0, "Error leak of nodes!!")
    }
    
    func test7_innerHTML() {
        let RESULT_TEST = "<!DOCTYPE html><html lang=\"en\"><head><title>Welcome title!!</title></head><body><h1>Welcome!</h1>text!<!--this is a comment--></body></html>"
        

        
        do {
            let parser = _createBasicHTML()
            if let div = parser.root.getNextNodeWithAtt(att: "dupl") {
                div.addNode(node: TextHTML(text: "text!"))
                div.addNode(node: CommentHTML(comment: "this is a comment"))
                div.replaceBy(string: div.innerHTML)
                XCTAssertEqual(div.innerHTML, "text!<!--this is a comment-->"
, "Error in innerHTML")
                
                XCTAssertEqual(parser.toHTML, RESULT_TEST, "Error in innerHTML")
            } else {
                XCTFail("reparseNode no realiced because error in getNextNodeWitAtt")
                
            }
        }
        XCTAssertEqual(HTMLNode.totalNodes, 0, "Error leak of nodes!!")
        
    }
    
    /*
    func test_checkBlanksConsistecy() {
        do {
            let html = try String(contentsOfFile: getPathTemplates() + "/test4.html")
            let parser = ParserHTML5(html: html)
                
            XCTAssertEqual(html, parser.toHTML, "The Result was differente in URL remote.")
        } catch let error {
            XCTFail("error load html for test: " + error.localizedDescription)
            
        }
    }
    */
    
    
    /*
     func testPerformanceExample() {
     // This is an example of a performance test case.
     self.measure {
     // Put the code you want to measure the time of here.
     }
     }
     */
    
    
    
}
