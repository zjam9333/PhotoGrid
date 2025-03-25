//
//  ShapeOverlayView.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/14.
//

import UIKit

class ShapeOverlayView: UIView {
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    var shapeLayer: CAShapeLayer? {
        return layer as? CAShapeLayer
    }
    
    func drawOverlayPolygon(_ polygon: [CGPoint], cornerRadius: CGFloat) {
        do {
            shapeLayer?.removeAnimation(forKey: "line")
            guard polygon.count >= 3 else {
                shapeLayer?.path = nil
                return
            }
            let path = UIBezierPath()
            path.addPolygon(polygon, cornerRadius: cornerRadius)
            shapeLayer?.path = path.cgPath
            shapeLayer?.fillColor = UIColor.clear.cgColor
            shapeLayer?.strokeColor = UIColor.cyan.cgColor
            shapeLayer?.lineWidth = 8
            shapeLayer?.lineDashPattern = [8, 4]
            
            let animation = CABasicAnimation(keyPath: "lineDashPhase")
            animation.fromValue = 0
            animation.toValue = shapeLayer?.lineDashPattern?.reduce(0) { $0 - $1.intValue } ?? 0
            animation.duration = 1
            animation.repeatCount = .infinity
            shapeLayer?.add(animation, forKey: "line")
        }
    }
    
    func cleanOverlayPolygon() {
        shapeLayer?.removeAnimation(forKey: "line")
        shapeLayer?.path = nil
    }
    
    deinit {
        shapeLayer?.removeAnimation(forKey: "line")
    }
}
