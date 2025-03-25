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
    
    func intersections(line: GGLine) -> [Element] {
        /// 判断点在线上
        /// 使用范围：求两条直线交点后使用
        func segmentContains(p1: CGPoint, p2: CGPoint, point: CGPoint) -> Bool {
            let minX = Swift.min(p1.x, p2.x) - 0.1 // 加减0.1忽略浮点数的精度
            let maxX = Swift.max(p1.x, p2.x) + 0.1
            let minY = Swift.min(p1.y, p2.y) - 0.1
            let maxY = Swift.max(p1.y, p2.y) + 0.1
            return point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY
        }
        
        let edges = toEdges()
        
        let intersects: [CGPoint] = edges.compactMap { e in
            guard let p = line.intersection(other: e) else {
                return nil
            }
            guard segmentContains(p1: e.p1, p2: e.p2, point: p) else {
                return nil
            }
            return p
        }
        return intersects
    }
}

/// 多边形向内收缩算法（已过时）
/// 太复杂且边界条件太多，不可靠，容易出现相交的结果
struct ShrinkPolygon {
    /// 这个老方法直接用向量平移，简单很多，但是生成的新边与旧边不平行，会产生轻微的旋转
    static private func shrinkPolygon2(_ polygon: [CGPoint], by distance: CGFloat) -> [CGPoint] {
        var shrunkPoints: [CGPoint] = []
        let count = polygon.count
        
        for i in 0..<count {
            let prevIndex = (i - 1 + count) % count
            let nextIndex = (i + 1) % count
            
            let prevPoint = polygon[prevIndex]
            let currentPoint = polygon[i]
            let nextPoint = polygon[nextIndex]
            
            // 计算相邻边的向量
            let vector1 = CGPoint(x: currentPoint.x - prevPoint.x, y: currentPoint.y - prevPoint.y)
            let vector2 = CGPoint(x: nextPoint.x - currentPoint.x, y: nextPoint.y - currentPoint.y)
            
            // 计算单位法向量
            let normal1 = CGPoint(x: -vector1.y, y: vector1.x).normalized()
            let normal2 = CGPoint(x: -vector2.y, y: vector2.x).normalized()
            
            // 计算角平分线向量
            let bisector = CGPoint(x: normal1.x + normal2.x, y: normal1.y + normal2.y).normalized()
            
            // 计算新的顶点位置
            let newX = currentPoint.x + bisector.x * distance
            let newY = currentPoint.y + bisector.y * distance
            let newPoint = CGPoint(x: newX, y: newY)
            
            shrunkPoints.append(newPoint)
        }
        
        return shrunkPoints
    }
    
    static func shrinkPolygon(_ polygon: [CGPoint], by distance: CGFloat) -> [CGPoint] {
        var newLines: [GGLine] = []
        let count = polygon.count
        for i in 0..<count {
            let p0 = polygon[i]
            let p1 = polygon[(i + 1) % count]
            let oldLine = GGLine(p1: p0, p2: p1)
            let shiftLine = oldLine.shifted(byDistance: distance)
            newLines.append(shiftLine)
        }
        var shrunkPoints: [CGPoint] = []
        
        for i in 0..<count {
            let prevIndex = (i - 1 + count) % count
            let l0 = newLines[prevIndex]
            let l1 = newLines[i]
            let newPoint = l0.intersection(other: l1)
            if let newPoint = newPoint {
                shrunkPoints.append(newPoint)
            }
        }
        
        return shrunkPoints
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
    
    func length() -> CGFloat {
        let length = sqrt(x * x + y * y)
        return length
    }
    
    func normalized() -> CGPoint {
        let length = length()
        if length == 0 {
            return self
        }
        return CGPoint(x: x / length, y: y / length)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    func dotProduct(with other: CGPoint) -> CGFloat {
        return x * other.x + y * other.y
    }
    
    func center(with other: CGPoint) -> CGPoint {
        let p1 = self
        let p2 = other
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
}

struct GGLine {
    var p1: CGPoint
    var p2: CGPoint
    
    var x1: CGFloat {
        return p1.x
    }
    
    var y1: CGFloat {
        return p1.y
    }
    
    var x2: CGFloat {
        return p2.x
    }
    
    var y2: CGFloat {
        return p2.y
    }
    
    func offset(_ offset: CGPoint) -> GGLine {
        return .init(x1: p1.x + offset.x, y1: p1.y + offset.y, x2: p2.x + offset.x, y2: p2.y + offset.y)
    }
    
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
        case left
        case right
    }
    
    /// 判断点在线的哪边？
    /// How to tell whether a point is to the right or left side of a line
    /// https://stackoverflow.com/questions/1560492/how-to-tell-whether-a-point-is-to-the-right-or-left-side-of-a-line
    /// ```
    ///      p2
    ///      ^
    ///      |
    /// left | right
    ///      |
    ///      p1
    /// ```
    ///
    func sideOf(point: CGPoint) -> Side {
        let a = p1
        let b = p2
        let c = point
        let determinant = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
        if (determinant == 0) {
            return .onLine
        } else if (determinant > 0) {
            return .right
        }
        return .left
    }
    
    var center: CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
    
    func shifted(byDistance distance: CGFloat) -> GGLine {
        // 计算直线的方向向量
        let directionVector = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
        // 法向量
        let normalVector = CGPoint(x: -directionVector.y, y: directionVector.x)
        // 归一化法向量
        let normalizedNormal = normalVector.normalized()
        
        // 计算平移后的点
        let translatedP1 = CGPoint(x: p1.x + distance * normalizedNormal.x, y: p1.y + distance * normalizedNormal.y)
        let translatedP2 = CGPoint(x: p2.x + distance * normalizedNormal.x, y: p2.y + distance * normalizedNormal.y)
        
        return GGLine(p1: translatedP1, p2: translatedP2)
    }
}

extension UIBezierPath {
    func addPolygon(_ polygon: [CGPoint], cornerRadius: CGFloat) {
        let path = self
        var usingPoints: [CGPoint] = []
        
        if cornerRadius > 0 {
            for i in 0..<polygon.count {
                let p0 = polygon[i]
                let p1 = polygon[(i + 1) % polygon.count]
                let dis = (p0 - p1).length()
                if (dis < 1) {
                    // 过滤挨太近的点
                    continue
                }
                usingPoints.append(p0)
            }
        } else {
            usingPoints = polygon
        }
        guard usingPoints.count >= 3 else {
            return
        }
        
        let begin = usingPoints[0].center(with: usingPoints[1])
        path.move(to: begin)
        for i in 0..<usingPoints.count {
            let p2 = usingPoints[(i + 1) % usingPoints.count]
            let p1 = usingPoints[i].center(with: p2)
            let p3 = usingPoints[(i + 2) % usingPoints.count].center(with: p2)
            if cornerRadius > 0 {
                let vec1 = p1 - p2
                let vec2 = p3 - p2
                let dotProd = vec1.dotProduct(with: vec2)
                let len1 = vec1.length()
                let len2 = vec2.length()
                let cosTheta = dotProd / (len1 * len2)
                let angle = acos(cosTheta)
                
                let minLen = min(len1, len2)
                let maxRadius = minLen * tan(angle / 2)
                
                let usingRadius = min(cornerRadius, maxRadius)
                
                let line0 = GGLine(p1: p1, p2: p2).shifted(byDistance: usingRadius)
                let line1 = GGLine(p1: p2, p2: p3).shifted(byDistance: usingRadius)
                
                let circleCenter = line0.intersection(other: line1) ?? .zero
                
                let startAngle = atan2(vec1.x, -vec1.y)
                let endAngle = startAngle + .pi - angle
                path.addArc(withCenter: circleCenter, radius: usingRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            } else {
                path.addLine(to: p2)
            }
        }
        path.addLine(to: begin)
    }
}
