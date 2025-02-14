//
//  Ext.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/13.
//

import Foundation
import UIKit

extension Array where Element == CGPoint {
    var left: CGFloat? {
        return self.min { p1, p2 in
            return p1.x < p2.x
        }?.x
    }
    
    var right: CGFloat? {
        return self.max { p1, p2 in
            return p1.x < p2.x
        }?.x
    }
    
    var top: CGFloat? {
        return self.min { p1, p2 in
            return p1.y < p2.y
        }?.y
    }
    
    var bottom: CGFloat? {
        return self.max { p1, p2 in
            return p1.y < p2.y
        }?.y
    }
    
    var center: CGPoint? {
        if isEmpty {
            return nil
        }
        var center = CGPoint.zero
        for p in self {
            center.x += p.x
            center.y += p.y
        }
        center.x /= CGFloat(count)
        center.y /= CGFloat(count)
        return center
    }
    
    /// 把多边形顶点按顺时针排序
    /// https://math.stackexchange.com/questions/978642/how-to-sort-vertices-of-a-polygon-in-counter-clockwise-order
    func sortClockwise() -> Array<Element> {
        if isEmpty {
            return self
        }
        guard let center = center else {
            return self
        }
        let pointAndDegree: [(CGPoint, CGFloat)] = map { p in
            let degree = atan2(p.x - center.x, p.y - center.y)
            return (p, degree)
        }
        let sortedDegrees = pointAndDegree.sorted { d1, d2 in
            return d1.1 > d2.1
        }
        let res = sortedDegrees.map { p1, d in
            return p1
        }
        return res
    }
    
    func toEdges() -> [GGLine] {
        if count < 2 {
            return []
        }
        var res: [GGLine] = []
        
        var lastPoint = self[0]
        for i in 1..<(count + 1) {
            let thisP = self[i % count]
            res.append(.init(p1: lastPoint, p2: thisP))
            lastPoint = thisP
        }
        return res
    }
}

extension CGRect {
    init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
         self = .init(x: left, y: top, width: right - left, height: bottom - top)
    }
    
    var top: CGFloat {
        return origin.y
    }
    
    var left: CGFloat {
        return origin.x
    }
    
    var bottom: CGFloat {
        return origin.y + size.height
    }
    
    var right: CGFloat {
        return origin.x + size.width
    }
    
    var topLeft: CGPoint {
        return .init(x: left, y: top)
    }
    
    var topRight: CGPoint {
        return .init(x: right, y: top)
    }
    
    var bottomLeft: CGPoint {
        return .init(x: left, y: bottom)
    }
    
    var bottomRight: CGPoint {
        return .init(x: right, y: bottom)
    }
}

extension CGPoint {
    /// 判断点在多边形内
    /// How to check if a given point lies inside or outside a polygon?
    /// https://www.geeksforgeeks.org/how-to-check-if-a-given-point-lies-inside-a-polygon/
    ///
    func liesInside(polygon: [CGPoint]) -> Bool {
        let num_vertices = polygon.count
        var inside = false
        
        guard var p1 = polygon.first else {
            return false
        }
        
        for i in 1..<(num_vertices + 1) {
            let p2 = polygon[i % num_vertices]
            if y > min(p1.y, p2.y) {
                if y <= max(p1.y, p2.y) {
                    if x <= max(p1.x, p2.x) {
                        let x_intersection = (y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x
                        if p1.x == p2.x || x < x_intersection {
                            inside = !inside
                        }
                    }
                }
            }
            p1 = p2
        }
        return inside
    }
    
    /// 判断点在多边形内
    /// 允许一点点的误差，特别是靠近边界的，因为0点几就误判了
    func almostLiesInside(polygon: [CGPoint]) -> Bool {
        let p = self
        if p.liesInside(polygon: polygon) {
            return true
        }
        // 差了0.几的误差
        if CGPoint(x: p.x + 1, y: p.y).liesInside(polygon: polygon) {
            return true
        }
        if CGPoint(x: p.x - 1, y: p.y).liesInside(polygon: polygon) {
            return true
        }
        if CGPoint(x: p.x, y: p.y + 1).liesInside(polygon: polygon) {
            return true
        }
        if CGPoint(x: p.x, y: p.y - 1).liesInside(polygon: polygon) {
            return true
        }
        return false
    }
}

struct GGLine {
    var p1: CGPoint
    var p2: CGPoint
    
    func reverted() -> GGLine {
        return .init(p1: p2, p2: p1)
    }
    
    init(p1: CGPoint, p2: CGPoint) {
        self.p1 = p1
        self.p2 = p2
    }
    
    init(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) {
        self.p1 = .init(x: x1, y: y1)
        self.p2 = .init(x: x2, y: y2)
    }
    
    /// 求两条直线的交点
    /// Program for Point of Intersection of Two Lines
    /// https://www.geeksforgeeks.org/program-for-point-of-intersection-of-two-lines/
    func intersection(other: GGLine) -> CGPoint? {
        let A = p1
        let B = p2
        let C = other.p1
        let D = other.p2
        
        // Line AB represented as a1x + b1y = c1
        let a1 = B.y - A.y
        let b1 = A.x - B.x
        let c1 = a1 * (A.x) + b1 * (A.y)
        
        // Line CD represented as a2x + b2y = c2
        let a2 = D.y - C.y
        let b2 = C.x - D.x
        let c2 = a2 * (C.x) + b2 * (C.y)
        
        let determinant = a1 * b2 - a2 * b1
        if (abs(determinant) < 0.000001) {
            // 几乎平行
            return nil
        }
        let x = (b2 * c1 - b1 * c2) / determinant
        let y = (a1 * c2 - a2 * c1) / determinant
        return .init(x: x, y: y)
    }
    
    enum Side {
        case onLine
        case a
        case b
    }
    
    /// 判断点在线的哪边？
    /// How to tell whether a point is to the right or left side of a line
    /// https://stackoverflow.com/questions/1560492/how-to-tell-whether-a-point-is-to-the-right-or-left-side-of-a-line
    func sideOf(point: CGPoint) -> Side {
        let a = p1
        let b = p2
        let c = point
        let determinant = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
        if (determinant == 0) {
            return .onLine
        } else if (determinant > 0) {
            return .b
        }
        return .a
    }
}
