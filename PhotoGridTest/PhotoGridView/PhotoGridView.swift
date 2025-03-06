//
//  PhotoGridView.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/13.
//

import UIKit

class PhotoGridView: UIView {
    var contentGetter: ((GridItem.Key) -> Any?)?
    
    private var cachePolyViews: [GridItem.Key: ImagePolygonView] = [:]
    private var cacheDragControl: [GridItem.Key: DragControl] = [:]
    
    private let overlayView = ShapeOverlayView()
    private let contentView = UIView()
    
    private var currentOverlayItem: GridItem? = nil
    
    private(set) var json: GridJson
    private var randomColor = PresetColors()
    
    func updateGrid(json: GridJson) {
        self.json = json
        randomColor = PresetColors()
        cachePolyViews.values.forEach { v in
            v.isHidden = true
        }
        cacheDragControl.values.forEach { v in
            v.isHidden = true
        }
        overlayView.overlayPolygon = []
//        cachePolyViews.removeAll()
//        cacheDragControl.removeAll()
        currentOverlayItem = nil
        
        func cacheItem(_ item: GridItem) {
            if let item = item as? GridPolygon {
                if let poly = cachePolyViews[item.key] {
                    poly.isHidden = false
                } else {
                    let poly = ImagePolygonView()
                    poly.backgroundColor = randomColor.next()
                    contentView.insertSubview(poly, at: 0)
                    cachePolyViews[item.key] = poly
                }
            } else if let item = item as? GridDivider {
                if let drag = cacheDragControl[item.key] {
                    drag.isHidden = true
                } else {
                    let dragView = DragControl()
                    dragView.frame = CGRect(origin: .zero, size: .init(width: 30, height: 30))
                    dragView.layer.cornerRadius = 15
                    dragView.backgroundColor = .cyan
                    dragView.isHidden = true
                    addSubview(dragView)
                    cacheDragControl[item.key] = dragView
                }
                cacheItem(item.left)
                cacheItem(item.right)
            }
        }
        cacheItem(json.item)
    }
    
    init(json: GridJson) {
        self.json = json
        super.init(frame: .zero)
        addSubview(contentView)
        addSubview(overlayView)
        updateGrid(json: json)
        overlayView.isUserInteractionEnabled = false
        contentView.backgroundColor = .black
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
        if json.borderWidth > 0 {
            rect = rect.insetBy(dx: json.borderWidth, dy: json.borderWidth)
        }
        let poly = [
            rect.topLeft,
            rect.bottomLeft,
            rect.topRight,
            rect.bottomRight,
        ].sortClockwise()
        
        draw(polygon: poly, item: json.item)
    }
    
    func refreshSubviewsContent() {
        for item in cachePolyViews {
            if let content = contentGetter?(item.key) as? UIImage {
                item.value.imageView.image = content
            } else {
                item.value.imageView.image = nil
            }
        }
    }
    
    private func draw(polygon: [CGPoint], item: GridItem) {
        guard let item = item as? GridDivider else {
            guard let item = item as? GridPolygon else {
                return
            }
            guard let poly: ImagePolygonView = cachePolyViews[item.key] else {
                return
            }
            
            let notEnough = polygon.count < 3 // 至少要3角形
            poly.isHidden = notEnough
            
            poly.setPolygon(points: polygon, cornerRadius: json.cornerRadius) // 多边形已经收缩过了，不需要内部再处理
            let controllableKeys: [Int] = item.controllableKeys
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
        
        let intersects = polygon.intersections(line: line)
        
        if let dragView: DragControl = cacheDragControl[item.key] {
            dragView.onDrag = { [weak self] touch in
                let pointInSelf = touch.location(in: self)
                let center = item.line.center
                let newOffset = CGPoint(x: pointInSelf.x - center.x, y: pointInSelf.y - center.y)
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
            if intersects.count >= 2 {
                dragView.center = GGLine(p1: intersects[0], p2: intersects[1]).center
                //            drag.isHidden = false
            } else {
                //            drag.isHidden = true
            }
        }
        // 通过分割线划分两个新的多边形
        var subPolygonLeft: [CGPoint] = intersects
        var subPolygonRight: [CGPoint] = intersects
        if json.lineWidth > 0 {
            // 使用左右偏移的两条线，分别切割，各取左边和右边
            let halfBorder = json.lineWidth / 2
            let shiftedLeft = line.shifted(byDistance: -halfBorder)
            subPolygonLeft = polygon.intersections(line: shiftedLeft)
            let shiftedRight = line.shifted(byDistance: halfBorder)
            subPolygonRight = polygon.intersections(line: shiftedRight)
            for p in polygon {
                // 注意这里side a还是side b跟线的方向有关系
                if shiftedLeft.sideOf(point: p) == .left {
                    subPolygonLeft.append(p)
                }
                if shiftedRight.sideOf(point: p) != .left {
                    subPolygonRight.append(p)
                }
            }
        } else {
            for p in polygon {
                // 注意这里side a还是side b跟线的方向有关系
                let position = line.sideOf(point: p)
                if position == .left {
                    subPolygonLeft.append(p)
                } else {
                    subPolygonRight.append(p)
                }
            }
        }
        
        draw(polygon: subPolygonLeft.sortClockwise(), item: item.left)
        draw(polygon: subPolygonRight.sortClockwise(), item: item.right)
    }
}

fileprivate class ImagePolygonView: MaskPolygonView {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
