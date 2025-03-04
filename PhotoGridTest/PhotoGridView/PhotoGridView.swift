//
//  PhotoGridView.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/13.
//

import UIKit

class PhotoGridView: UIView {
    
    var borderWidth: CGFloat = 0
    var contentGetter: ((GridItem.Key) -> Any?)?
    
    private var cachePolyViews: [GridItem.Key: ImagePolygonView] = [:]
    private var cacheDragControl: [GridItem.Key: DragControl] = [:]
    
    private let overlayView = ShapeOverlayView()
    private let contentView = UIView()
    
    private var currentOverlayItem: GridItem? = nil
    
    private var json: GridJson
    private var randomColor = PresetColors()
    
    func updateGrid(json: GridJson) {
        self.json = json
        randomColor = PresetColors()
        cachePolyViews.removeAll()
        cacheDragControl.removeAll()
        contentView.subviews.forEach { v in
            v.removeFromSuperview()
        }
        currentOverlayItem = nil
    }
    
    init(json: GridJson) {
        self.json = json
        super.init(frame: .zero)
        updateGrid(json: json)
        addSubview(contentView)
        addSubview(overlayView)
        overlayView.isUserInteractionEnabled = false
        backgroundColor = .black
    }
    
    var snapshotView: UIView {
        return contentView
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
        var rect = bounds
        if borderWidth > 0 {
            rect = rect.insetBy(dx: borderWidth / 2, dy: borderWidth / 2)
        }
        let poly = [
            rect.topLeft,
            rect.bottomLeft,
            rect.topRight,
            rect.bottomRight,
        ].sortClockwise()
        
        draw(polygon: poly, item: json.item, parentLine: nil)
    }
    
    func refreshSubviewsContent() {
        for item in cachePolyViews {
            if let content = contentGetter?(item.key) as? UIImage {
                item.value.imageView.image = content
            }
        }
    }
    
    private func draw(polygon: [CGPoint], item: GridItem, parentLine: GridDivider?) {
        guard let item = item as? GridDivider else {
            let poly: ImagePolygonView = cachePolyViews[item.key] ?? {
                let polyView = ImagePolygonView()
                contentView.insertSubview(polyView, at: 0)
                polyView.backgroundColor = randomColor.next()
                cachePolyViews[item.key] = polyView
                return polyView
            }()
            
            let notEnough = polygon.count < 3 // 至少要3角形
            poly.isHidden = notEnough
            
            poly.setPolygon(points: polygon, borderWidth: borderWidth / 2)
            let controllableKeys: [Int] = (item as? GridPolygon)?.controllableKeys ?? []
            poly.onTap = { [weak self, weak item] in
                self?.cacheDragControl.values.forEach { drag in
                    drag.isHidden = true
                }
                if item?.key == self?.currentOverlayItem?.key {
                    self?.currentOverlayItem = nil
                    self?.overlayView.overlayPolygon = []
                } else {
                    self?.currentOverlayItem = item
                    self?.overlayView.overlayPolygon = polygon
                    for key in controllableKeys {
                        self?.cacheDragControl[key]?.isHidden = false
                    }
                }
            }
            if (item.key == currentOverlayItem?.key) {
                overlayView.overlayPolygon = polygon
            }
            return
        }
        
        let line = item.line.offset(item.offset)
        
        let edges = polygon.toEdges()
        let polygonOuterRect = CGRect(top: polygon.top ?? 0, left: polygon.left ?? 0, bottom: polygon.bottom ?? 0, right: polygon.right ?? 0).insetBy(dx: -1, dy: -1)
        
        let intersects: [CGPoint] = edges.compactMap { e in
            guard let p = line.intersection(other: e) else {
                return nil
            }
            if polygonOuterRect.contains(p) && p.almostLiesInside(polygon: polygon) {
                return p
            }
            return nil
        }
        
        let drag: DragControl = cacheDragControl[item.key] ?? {
            let dragView = DragControl()
            addSubview(dragView)
            dragView.backgroundColor = .gray
            dragView.frame = CGRect(origin: line.center, size: .init(width: 30, height: 30))
            dragView.layer.cornerRadius = 15
            dragView.onDrag = { [weak self] touch in
                let pointInSelf = touch.location(in: self)
                let center = item.line.center
                let newOffset = CGVector(dx: pointInSelf.x - center.x, dy: pointInSelf.y - center.y)
                item.offset = newOffset
                
                let syncGroup = Set(item.syncGroup)
                func findAndSync(item: GridItem?) {
                    guard let item = item as? GridDivider else {
                        return
                    }
                    if syncGroup.contains(item.key) {
                        item.offset = newOffset
                    }
                    findAndSync(item: item.left)
                    findAndSync(item: item.right)
                }
                findAndSync(item: self?.json.item)
                
                self?.refreshSubviewsFrame()
            }
            dragView.transform = .init(rotationAngle: atan2(line.p1.x - line.p2.x, line.p2.y - line.p1.y) + .pi / 2)
            cacheDragControl[item.key] = dragView
            dragView.isHidden = true
            return dragView
        }()
        if intersects.count >= 2 {
            drag.center = GGLine(p1: intersects[0], p2: intersects[1]).center
//            drag.isHidden = false
        } else {
//            drag.isHidden = true
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

fileprivate class ImagePolygonView: MaskPolygonView {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
