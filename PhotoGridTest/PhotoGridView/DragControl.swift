//
//  DragControl.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/27.
//

import UIKit

class DragControl: UIView {
    var onDrag: ((UITouch) -> Void)?
    
    private var maskPolyPoints: [CGPoint] = []
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let pInside = point.liesInside(polygon: maskPolyPoints)
        if !pInside {
            return nil
        }
        return super.hitTest(point, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let first = touches.first else {
            return
        }
        onDrag?(first)
    }
    
    func locate(p1: CGPoint, p2: CGPoint, lineWidth: CGFloat) {
        let line = GGLine(p1: p1, p2: p2)
        let usingWidth = max(abs(lineWidth), 10) / 2
        let lineRight = line.shifted(byDistance: usingWidth)
        let lineLeft = line.shifted(byDistance: -usingWidth)
        let points = [lineRight.p2, lineRight.p1, lineLeft.p1, lineLeft.p2]
        
        guard let top = points.top, let bottom = points.bottom, let left = points.left, let right = points.right else {
            return;
        }
        
        let fra = CGRect(top: top, left: left, bottom: bottom, right: right)
        frame = fra
        
        maskPolyPoints = points.map { p in
            return CGPoint(x: p.x - fra.origin.x, y: p.y - fra.origin.y)
        }
    }
}
