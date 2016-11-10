
# What is this?
This package was designed to parse HTML 5 files for Brilliant Template. However, it can also be used independently.

Attention, this package uses IBM HTML Entities:
https://github.com/IBM-Swift/swift-html-entities.git
This package will be replaced by the OWASP XSS Prevention Cheat Sheet.


# Shortly...
* Add XSS prevention cheat sheet by OWASP: https://www.owasp.org/index.php/XSS_%28Cross_Site_Scripting%29_Prevention_Cheat_Sheet


# Installation

First step: create a new directory with this files:


*Package.swift*
```swift

import PackageDescription

let package = Package(
    name: "MyTest",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/ucotta/BrilliantHTML5Parser.git", majorVersion: 0)
    ],
    exclude: []
)
```

*Sources/MyTest/main.swift*

```swift
import Foundation

import BrilliantHTML5Parser

var data: [String: Any] = [
    "title": "This is the title",
    "welcome": "this is your first example!!",
    "more": "and you can do a lot of stuff",
    "buttonColor": "btn-blue btn-sm btn"
]

let URLINDEX = "https://raw.githubusercontent.com/ucotta/BrilliantHTML5Parser/master/examples/index.html"
if let url = URL(string: URLINDEX) {
    var html = try String(contentsOf: url)
    print("Input HTML:")
    print(html)

    let parser = ParserHTML5(html: html)
    while let item = parser.root.getNextTid() {
        if let val = data[item["tid"]!] {
            item.removeNodes()
            item.addNode(node: TextHTML(text: val as! String))
        }
        item["tid"] = nil
    }

    while let item = parser.root.getNextAid() {
        if let val = data[item["aid"]!] {
            item["class"] = val as! String
        }
        item["aid"] = nil
    }
    print(parser.toHTML)
}


```

Second step: build the project

```bash
swift package generate-xcodeproj 
```

Open the Xcode project, select the correct scheme and run!   


# Usage:

## Create an HTML5 from scratch

```swift

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

// Now print result.
print(parser.toHTML)
```

You will get this (but you won't see it tabbed)

```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Welcome title!!</title>
    </head>
<body>
    <h1>Welcome!</h1>
    <div dupl="3"></div>
</body>
</html>

```

If you'd like to have a tabbed result, please feel free to request this feature in ISSUES. 


## Parsing an HTML5 and commenting a div 

```swift

let parser = ParserHTML5(html: "somehtmlhere with a div with attribute dupl")

if let div = parser.root.getNextNodeWithAtt(att: "dupl") {
    // first comment the div with att dupl=3
    div.parentNode?.addNode(node: CommentHTML(comment: div.toHTML))
    // Delete the node.
    div.parentNode = nil
    
    print(parser.toHTML)
} else {
    print("The HTML doesnt contains a div with an attribute named *dupl*") 
}

```


## More examples in testing unit:

[BrilliantHTML5ParserTest](https://github.com/ucotta/BrilliantHTML5Parser/blob/master/BrilliantHTML5ParserTest/BrilliantHTML5ParserTest.swift)




