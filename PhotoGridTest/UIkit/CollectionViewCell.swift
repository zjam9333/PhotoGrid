//
//  CollectionViewCell.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/3/3.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    var redView: PhotoGridView!
    
    var model: Model! {
        didSet {
            redView.updateGrid(json: model.gridJson)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        redView = PhotoGridView(json: .init(width: 320, height: 320, item: .random()))
        redView.frame = CGRect(origin: .zero, size: .init(width: 320, height: 320))
        redView.isUserInteractionEnabled = false
        contentView.addSubview(redView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        redView.transform = .identity
        redView.frame = .init(x: 0, y: 0, width: model.gridJson.width, height: model.gridJson.height)
        let scaleX = bounds.size.width / model.gridJson.width
        let scaleY = bounds.size.height / model.gridJson.height
        redView.transform = .init(scaleX: scaleX, y: scaleY)
        redView.frame = bounds
        
        redView.refreshSubviewsFrame()
    }
}

extension CollectionViewCell {
    class Model: Hashable {
        static func == (lhs: CollectionViewCell.Model, rhs: CollectionViewCell.Model) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        let id = UUID()
        
        var gridJson: GridJson
        
        init(gridJson: GridJson) {
            self.gridJson = gridJson
        }
        
        init(originalJson: String) {
            let dict = try? JSONSerialization.jsonObject(with: originalJson.data(using: .utf8)!) as? [String: Any]
            
            gridJson = GridJson.fromJson(dict ?? [:])
        }
    }
}
