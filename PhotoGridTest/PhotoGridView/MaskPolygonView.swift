//
//  MaskView.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/13.
//

import UIKit

class MaskPolygonView: UIView {
    let contentView = UIView()
    private var maskPolyPoints: [CGPoint] = []
    
    private let maskLayer = CAShapeLayer()
    
    var onTap: (() -> Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.mask = maskLayer
        addSubview(contentView)
        
        let tapG = UITapGestureRecognizer(target: self, action: #selector(onTapGesture))
        addGestureRecognizer(tapG)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.frame = bounds
    }
    
    func setPolygon(points: [CGPoint], cornerRadius: CGFloat) {
        guard let top = points.top, let bottom = points.bottom, let left = points.left, let right = points.right else {
            return;
        }
        
        let fra = CGRect(top: top, left: left, bottom: bottom, right: right)
        frame = fra
        
        contentView.frame = .init(origin: .zero, size: fra.size)
        
        maskPolyPoints = points.map { p in
            return CGPoint(x: p.x - fra.origin.x, y: p.y - fra.origin.y)
        }
        
        let usingPoints = maskPolyPoints
        
        if usingPoints.count < 3 {
            maskLayer.path = nil
            return
        }
        
        let path = UIBezierPath()
        let begin = usingPoints[0].center(with: usingPoints[1])
        path.move(to: begin)
        for i in 0..<usingPoints.count {
            let p2 = usingPoints[(i + 1) % usingPoints.count]
            let p1 = usingPoints[i].center(with: p2)
            let p3 = usingPoints[(i + 2) % usingPoints.count].center(with: p2)
            path.addLine(to: p1.center(with: p2))
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
            path.addLine(to: p2.center(with: p3))
        }
        maskLayer.path = path.cgPath
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let pInside = point.liesInside(polygon: maskPolyPoints)
        if !pInside {
            return nil
        }
        return super.hitTest(point, with: event)
    }
    
    @objc func onTapGesture() {
        onTap?()
    }
}
