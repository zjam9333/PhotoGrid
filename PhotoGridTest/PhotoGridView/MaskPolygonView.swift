//
//  MaskView.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/13.
//

import UIKit

class MaskPolygonView: UIView {
    private var maskPolyPoints: [CGPoint] = []
    
    private let maskLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.mask = maskLayer
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.frame = bounds
    }
    
    func setPolygon(points: [CGPoint]) {
        guard let top = points.top, let bottom = points.bottom, let left = points.left, let right = points.right else {
            return;
        }
        
        let fra = CGRect(top: top, left: left, bottom: bottom, right: right)
        frame = fra
        
        maskPolyPoints = points.map { p in
            return CGPoint(x: p.x - fra.origin.x, y: p.y - fra.origin.y)
        }
        let path = UIBezierPath()
        guard let first = maskPolyPoints.first else {
            return
        }
        path.move(to: first)
        for p in maskPolyPoints.dropFirst() {
            path.addLine(to: p)
        }
        path.close()
        maskLayer.path = path.cgPath
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let pInside = point.liesInside(polygon: maskPolyPoints)
        if !pInside {
            return nil
        }
        return super.hitTest(point, with: event)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // test
        print("ok", "touchesBegan", self, Date())
        super.touchesBegan(touches, with: event)
    }
}
