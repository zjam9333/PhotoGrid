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

class GridJson: FromJSON {
    let width: CGFloat
    let height: CGFloat
    let item: GridItem
    
    init(width: CGFloat, height: CGFloat, item: GridItem) {
        self.width = width
        self.height = height
        self.item = item
    }
    
    class func fromJson(_ json: [String: Any]) -> GridJson {
        let width = json["width"] as? CGFloat ?? 0
        let height = json["height"] as? CGFloat ?? 0
        let item = GridItem.fromJson(json["item"] as? [String: Any] ?? [:])
        return .init(width: width, height: height, item: item)
    }
    
    func toJson() -> [String : Any] {
        return [
            "width": width,
            "height": height,
            "item": item.toJson(),
        ]
    }
}

class GridItem: FromJSON {
    typealias Key = Int
    
    let key: Key
    
    init(key: Key) {
        self.key = key
    }
    
    static func random() -> GridItem {
        return .init(key: UUID().hashValue)
    }
    
    var asDivider: GridDivider? {
        return self as? GridDivider
    }
    
    var asPolygon: GridPolygon? {
        return self as? GridPolygon
    }
    
    class func fromJson(_ json: [String: Any]) -> GridItem {
        let type = json["type"] as? String ?? "";
        switch type {
        case "line":
            return GridDivider.fromJson(json)
        case "polygon":
            return GridPolygon.fromJson(json)
        default:
            return GridItem.random()
        }
    }
    
    func toJson() -> [String : Any] {
        return [:]
    }
}
    
class GridDivider: GridItem {
    let line: GGLine
    var left: GridItem
    var right: GridItem
    var offset: CGVector
    let syncGroup: [Key]
    
    init(key: Key, line: GGLine, left: GridItem = .random(), right: GridItem = .random(), offset: CGVector = .zero, syncGroup: [Key] = []) {
        self.line = line
        self.left = left
        self.right = right
        self.offset = offset
        self.syncGroup = syncGroup
        super.init(key: key)
    }
    
    override class func fromJson(_ json: [String: Any]) -> GridItem {
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
        
        return GridDivider(key: key, line: .init(x1: x1, y1: y1, x2: x2, y2: y2), left: left, right: right, offset: .init(dx: dx, dy: dy), syncGroup: syncGroup)
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
                "dx": offset.dx,
                "dy": offset.dy,
            ],
            "left": left.toJson(),
            "right": right.toJson(),
            "syncGroup": syncGroup,
        ]
    }
}

class GridPolygon: GridItem {
    var content: Any? = nil
    let controllableKeys: [Key]
    
    init(key: Key, controllableKeys: [Key]) {
        self.controllableKeys = controllableKeys
        super.init(key: key)
    }
    
    override class func fromJson(_ json: [String : Any]) -> GridItem {
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
}
