//
//  PhotoGridView.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/13.
//

import UIKit

enum Grid {
    class Item: Hashable {
        
        let key = UUID()
        var content: Any? = nil
        
        var asLine: Divider? {
            return self as? Divider
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(key)
        }
        
        static func == (lhs: Grid.Item, rhs: Grid.Item) -> Bool {
            return lhs.key == rhs.key
        }
    }
    
    class Divider: Item {
        var line: GGLine
        var left: Item
        var right: Item
        
        init(line: GGLine, left: Item = .init(), right: Item = .init()) {
            self.line = line
            self.left = left
            self.right = right
        }
    }
}

class PhotoGridView: UIView {
    
    var cachePolyViews: [Grid.Item: MaskPolygonView] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func refreshSubviewsFrame() {
        testLines()
    }
    
    private func testLines() {
        let line0 = GGLine(x1: 0, y1: bounds.size.height / 3, x2: bounds.size.width, y2: bounds.size.height / 4)
        let item = Grid.Divider(line: line0)
        
        let line1 = GGLine(x1: bounds.size.width / 3, y1: 0, x2: bounds.size.width / 3 - 40, y2: bounds.size.height).reverted()
        item.left = Grid.Divider(line: line1)
//
        let line2 = GGLine(x1: bounds.size.width / 3 + 40, y1: 0, x2: bounds.size.width / 3 + 40 + 40, y2: bounds.size.height).reverted()
        item.right = Grid.Divider(line: line2)
        
        let poly = [
            bounds.topLeft,
            bounds.bottomLeft,
            bounds.topRight,
            bounds.bottomRight,
        ].sortClockwise()
        
        draw(polygon: poly, item: item, parentLine: nil)
    }
    
    private var randomColor = PresetColors()
    
    private func draw(polygon: [CGPoint], item: Grid.Item, parentLine: Grid.Divider?) {
        guard let item = item as? Grid.Divider else {
            var poly: MaskPolygonView? = cachePolyViews[item]
            if poly == nil {
                let polyView = MaskPolygonView()
                addSubview(polyView)
                polyView.backgroundColor = randomColor.next()
                cachePolyViews[item] = polyView
                poly = polyView
            }
            poly?.setPolygon(points: polygon)
            return
        }
        
        let line = item.line
        
        let edges = polygon.toEdges()
        let intersects: [CGPoint] = edges.compactMap { e in
            guard let p = line.intersection(other: e) else {
                return nil
            }
            if p.almostLiesInside(polygon: polygon) {
                return p
            }
            return nil
        }
        
        // 通过分割线划分两个新的多边形
        var subPolygon0: [CGPoint] = [] + intersects
        var subPolygon1: [CGPoint] = [] + intersects
        for p in polygon {
            // 注意这里side a还是side b跟线的方向有关系
            let position = line.sideOf(point: p)
            if position == .a {
                subPolygon0.append(p)
            } else {
                subPolygon1.append(p)
            }
        }
        
        draw(polygon: subPolygon0.sortClockwise(), item: item.left, parentLine: item)
        draw(polygon: subPolygon1.sortClockwise() ,item: item.right, parentLine: item)
    }
}
