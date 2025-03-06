//
//  Untitled.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/3/5.
//

import UIKit

class TestPathView: UIView {
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    var shapeLayer: CAShapeLayer? {
        return layer as? CAShapeLayer
    }
    
    var radius: CGFloat = 20
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        radius = CGFloat(sender.value)
        drrrr()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = Float(radius)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        addSubview(slider)
        slider.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview()
            make.width.equalTo(200)
        }
        
        drrrr()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drrrr() {
        subviews.forEach { view in
            if view is UISlider == false {
                view.removeFromSuperview()
            }
        }
        do {
            let p1 = CGPoint(x: 0, y: 0)
            let p2 = CGPoint(x: 0, y: 10)
            let p3 = CGPoint(x: 10, y: 10)
            addPoint(p1, color: .black)
            addPoint(p2, color: .black)
            addPoint(p3, color: .black)
        }
        
        let p3 = CGPoint(x: 10, y: 30)
        let p1 = CGPoint(x: 100, y: 50)
        let p2 = CGPoint(x: 50, y: 200)
        
        addPoint(p1, color: .red)
        addPoint(p2, color: .red)
        addPoint(p3, color: .red)
        
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p1)
        
        if radius > 0 {
            let vec1 = p1 - p2
            let vec2 = p3 - p2
            let dotProd = vec1.dotProduct(with: vec2)
            let len1 = vec1.length()
            let len2 = vec2.length()
            let cosTheta = dotProd / (len1 * len2)
            let angle = acos(cosTheta)
            
            let minLen = min(len1, len2)
            let maxRadius = minLen * tan(angle / 2)
            
            let usingRadius = min(radius, maxRadius)
            
            let line0 = GGLine(p1: p1, p2: p2).shifted(byDistance: usingRadius)
            let line1 = GGLine(p1: p2, p2: p3).shifted(byDistance: usingRadius)
            
            let circleCenter = line0.intersection(other: line1) ?? .zero
            addPoint(circleCenter, color: .green)
            
            let startAngle = atan2(vec1.x, -vec1.y)
            let endAngle = startAngle + .pi - angle
            path.addArc(withCenter: circleCenter, radius: usingRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        } else {
            path.addLine(to: p2)
        }
        path.addLine(to: p3)
//        path.addLine(to: p1)
//        path.addLine(to: circleCenter)
        shapeLayer?.path = path.cgPath
        shapeLayer?.fillColor = UIColor.gray.cgColor
    }
    
    func addPoint(_ p: CGPoint, color: UIColor) {
        let c = UIView(frame: .init(x: 0, y: 0, width: 3, height: 3))
        c.center = p
        c.backgroundColor = color
        addSubview(c)
    }
}
