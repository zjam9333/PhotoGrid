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
    
    func setPolygon(points: [CGPoint]) {
        guard let top = points.top, let bottom = points.bottom, let left = points.left, let right = points.right else {
            return;
        }
        
        let fra = CGRect(top: top, left: left, bottom: bottom, right: right)
        frame = fra
        
        maskPolyPoints = points.map { p in
            return CGPoint(x: p.x - fra.origin.x, y: p.y - fra.origin.y)
        }
        
        let usingPoints = maskPolyPoints
        
        let path = UIBezierPath()
        guard let first = usingPoints.first else {
            return
        }
        path.move(to: first)
        for p in usingPoints.dropFirst() {
            path.addLine(to: p)
        }
        path.close()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .nonZero
        
        contentView.frame = CGRect(top: usingPoints.top ?? 0, left: usingPoints.left ?? 0, bottom: usingPoints.bottom ?? 0, right: usingPoints.right ?? 0).insetBy(dx: -1, dy: -1)
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
