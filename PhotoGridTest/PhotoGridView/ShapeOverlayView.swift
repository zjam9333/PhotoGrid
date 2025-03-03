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
    
    var overlayPolygon: [CGPoint] = [] {
        didSet {
            guard let first = overlayPolygon.first else {
                shapeLayer?.path = nil
                return
            }
            let path = UIBezierPath()
            path.move(to: first)
            for p in overlayPolygon.dropFirst() {
                path.addLine(to: p)
            }
            path.close()
            shapeLayer?.path = path.cgPath
            shapeLayer?.fillColor = UIColor.clear.cgColor
            shapeLayer?.strokeColor = UIColor.gray.cgColor
            shapeLayer?.lineWidth = 2
            shapeLayer?.lineDashPattern = [8, 4]
        }
    }
}
