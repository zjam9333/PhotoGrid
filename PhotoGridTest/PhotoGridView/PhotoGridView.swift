//
//  PhotoGridView.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/13.
//

import UIKit

class PhotoGridView: UIView {
    
    private var cachePolyViews: [GridItem: MaskPolygonView] = [:]
    
    private let overlayView = ShapeOverlayView()
    private let contentView = UIView()
    
    private var currentOverlayItem: GridItem? = nil
    
    var item: GridItem
    
    init(item: GridItem) {
        self.item = item
        super.init(frame: .zero)
        addSubview(contentView)
        addSubview(overlayView)
        overlayView.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        overlayView.frame = bounds
        contentView.frame = bounds
    }
    
    func refreshSubviewsFrame() {
        let poly = [
            bounds.topLeft,
            bounds.bottomLeft,
            bounds.topRight,
            bounds.bottomRight,
        ].sortClockwise()
        
        draw(polygon: poly, item: item, parentLine: nil)
    }
    
    private var randomColor = PresetColors()
    
    private func draw(polygon: [CGPoint], item: GridItem, parentLine: GridDivider?) {
        guard let item = item as? GridDivider else {
            var poly: MaskPolygonView? = cachePolyViews[item]
            if poly == nil {
                let polyView = MaskPolygonView()
                contentView.addSubview(polyView)
                polyView.backgroundColor = randomColor.next()
                cachePolyViews[item] = polyView
                poly = polyView
            }
            guard let poly = poly else {
                return
            }
            
            let notEnough = polygon.count < 3 // 至少要3角形
            poly.isHidden = notEnough
            
            poly.setPolygon(points: polygon)
            poly.onTap = { [weak self] in
                if item == self?.currentOverlayItem {
                    self?.currentOverlayItem = nil
                    self?.overlayView.overlayPolygon = []
                } else {
                    self?.currentOverlayItem = item
                    self?.overlayView.overlayPolygon = polygon
                }
            }
            if (item == currentOverlayItem) {
                overlayView.overlayPolygon = polygon
            }
            return
        }
        
        let line = item.line.offset(item.offset)
        
        let edges = polygon.toEdges()
        let intersects: [CGPoint] = edges.compactMap { e in
            guard let p = line.intersection(other: e) else {
                return nil
            }
            if p.almostLiesInside(polygon: polygon) {
                return p
            }
            return nil
        }
        
        // 通过分割线划分两个新的多边形
        var subPolygon0: [CGPoint] = [] + intersects
        var subPolygon1: [CGPoint] = [] + intersects
        for p in polygon {
            // 注意这里side a还是side b跟线的方向有关系
            let position = line.sideOf(point: p)
            if position == .a {
                subPolygon0.append(p)
            } else {
                subPolygon1.append(p)
            }
        }
        
        draw(polygon: subPolygon0.sortClockwise(), item: item.left, parentLine: item)
        draw(polygon: subPolygon1.sortClockwise() ,item: item.right, parentLine: item)
    }
}
