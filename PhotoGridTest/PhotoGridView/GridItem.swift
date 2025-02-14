//
//  GridItem.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/14.
//

import Foundation

class GridItem: Hashable {
        
    let key = UUID()
    var content: Any? = nil
    
    var asDivider: GridDivider? {
        return self as? GridDivider
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    static func == (lhs: GridItem, rhs: GridItem) -> Bool {
        return lhs.key == rhs.key
    }
}
    
class GridDivider: GridItem {
    let line: GGLine
    var left: GridItem
    var right: GridItem
    var offset: CGVector
    
    init(line: GGLine, left: GridItem = .init(), right: GridItem = .init(), offset: CGVector = .zero) {
        self.line = line
        self.left = left
        self.right = right
        self.offset = offset
    }
}

