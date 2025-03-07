//
//  GridItem.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/14.
//

import Foundation

protocol FromJSON: AnyObject {
    associatedtype Result
    static func fromJson(_ json: [String: Any]) -> Result
    func toJson() -> [String: Any]
}

protocol Scalable: AnyObject {
    associatedtype Result
    func scaled(_ scaleX: CGFloat, scaleY: CGFloat) -> Result
}

class GridJson: FromJSON, Scalable {
    let width: CGFloat
    let height: CGFloat
    
    var borderWidth: CGFloat
    var lineWidth: CGFloat
    var cornerRadius: CGFloat
    
    let item: GridItem
    
    init(width: CGFloat, height: CGFloat, borderWidth: CGFloat = 0, lineWidth: CGFloat = 0, cornerRadius: CGFloat = 0, item: GridItem) {
        self.width = width
        self.height = height
        self.borderWidth = borderWidth
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.item = item
    }
    
    class func fromJson(_ json: [String: Any]) -> GridJson {
        let width = json["width"] as? CGFloat ?? 0
        let height = json["height"] as? CGFloat ?? 0
        let item = GridItem.fromJson(json["item"] as? [String: Any] ?? [:])
        let borderWidth = json["borderWidth"] as? CGFloat ?? 0
        let lineWidth = json["lineWidth"] as? CGFloat ?? 0
        let cornerRadius = json["cornerRadius"] as? CGFloat ?? 0
        return .init(
            width: width,
            height: height,
            borderWidth: borderWidth,
            lineWidth: lineWidth,
            cornerRadius: cornerRadius,
            item: item
        )
    }
    
    func toJson() -> [String : Any] {
        return [
            "width": width,
            "height": height,
            "borderWidth": borderWidth,
            "lineWidth": lineWidth,
            "cornerRadius": cornerRadius,
            "item": item.toJson(),
        ]
    }
    
    func scaled(toSize size: CGSize) -> GridJson {
        let scaleX = size.width / width
        let scaleY = size.height / height
        return GridJson(
            width: size.width,
            height: size.height,
            borderWidth: borderWidth * scaleX, // 用x的比例吧，通常缩放会与y相同的
            lineWidth: lineWidth * scaleX,
            cornerRadius: cornerRadius * scaleX,
            item: item.scaled(scaleX, scaleY: scaleY)
        )
    }
    
    func scaled(_ scaleX: CGFloat, scaleY: CGFloat) -> GridJson {
        return scaled(toSize: .init(width: scaleX * width, height: scaleY * height))
    }
}

class GridItem: FromJSON, Scalable {
    typealias Key = Int
    
    let key: Key
    
    init(key: Key) {
        self.key = key
    }
    
    static func random() -> GridItem {
        return .init(key: UUID().hashValue)
    }
    
    class func fromJson(_ json: [String: Any]) -> GridItem {
        let type = json["type"] as? String ?? "";
        switch type {
        case "line":
            return GridLine.fromJson(json)
        case "polygon":
            return GridPolygon.fromJson(json)
        default:
            return GridItem.random()
        }
    }
    
    func toJson() -> [String : Any] {
        return [:]
    }
    
    func scaled(_ scaleX: CGFloat, scaleY: CGFloat) -> GridItem {
        return .init(key: key)
    }
}
    
class GridLine: GridItem {
    let line: GGLine
    var left: GridItem
    var right: GridItem
    var offset: CGPoint
    let syncGroup: [Key]
    
    init(key: Key, line: GGLine, left: GridItem = .random(), right: GridItem = .random(), offset: CGPoint = .zero, syncGroup: [Key] = []) {
        self.line = line
        self.left = left
        self.right = right
        self.offset = offset
        self.syncGroup = syncGroup
        super.init(key: key)
    }
    
    override class func fromJson(_ json: [String: Any]) -> GridLine {
        let key = json["key"] as? Int ?? 0
        
        let line = json["line"] as? [String: Any]
        let x1 = line?["x1"] as? CGFloat ?? 0
        let y1 = line?["y1"] as? CGFloat ?? 0
        let x2 = line?["x2"] as? CGFloat ?? 0
        let y2 = line?["y2"] as? CGFloat ?? 0
        
        let offset = json["offset"] as? [String: Any]
        let dx = offset?["dx"] as? CGFloat ?? 0
        let dy = offset?["dy"] as? CGFloat ?? 0
        
        let syncGroup = json["syncGroup"] as? [Key] ?? []
        
        let left = GridItem.fromJson(json["left"] as? [String: Any] ?? [:])
        let right = GridItem.fromJson(json["right"] as? [String: Any] ?? [:])
        
        return .init(
            key: key,
            line: .init(x1: x1, y1: y1, x2: x2, y2: y2),
            left: left,
            right: right,
            offset: .init(x: dx, y: dy),
            syncGroup: syncGroup
        )
    }
    
    override func toJson() -> [String : Any] {
        return [
            "type": "line",
            "key": key,
            "line": [
                "x1": line.x1,
                "y1": line.y1,
                "x2": line.x2,
                "y2": line.y2,
            ],
            "offset": [
                "dx": offset.x,
                "dy": offset.y,
            ],
            "left": left.toJson(),
            "right": right.toJson(),
            "syncGroup": syncGroup,
        ]
    }
    
    override func scaled(_ scaleX: CGFloat, scaleY: CGFloat) -> GridLine {
        return .init(
            key: key,
            line: .init(x1: line.x1 * scaleX, y1: line.y1 * scaleY, x2: line.x2 * scaleX, y2: line.y2 * scaleY),
            left: left.scaled(scaleX, scaleY: scaleY),
            right: right.scaled(scaleX, scaleY: scaleY),
            offset: .init(x: offset.x * scaleX, y: offset.y * scaleY),
            syncGroup: syncGroup
        )
    }
}

class GridPolygon: GridItem {
    var content: Any? = nil
    let controllableKeys: [Key]
    
    init(key: Key, controllableKeys: [Key]) {
        self.controllableKeys = controllableKeys
        super.init(key: key)
    }
    
    override class func fromJson(_ json: [String : Any]) -> GridPolygon {
        let key = json["key"] as? Int ?? 0
        let controllableKeys = json["controllableKeys"] as? [Key] ?? []
        return GridPolygon(key: key, controllableKeys: controllableKeys)
    }
    
    override func toJson() -> [String : Any] {
        return [
            "type": "polygon",
            "key": key,
            "controllableKeys": controllableKeys,
        ]
    }
    
    override func scaled(_ scaleX: CGFloat, scaleY: CGFloat) -> GridPolygon {
        return .init(key: key, controllableKeys: controllableKeys)
    }
}
