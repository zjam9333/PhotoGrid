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
        path.addPolygon(usingPoints, cornerRadius: cornerRadius)
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
