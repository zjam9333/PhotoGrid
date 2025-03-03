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
            redView.item = model.gridJson.item
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        redView = PhotoGridView(item: .random())
        redView.frame = CGRect(origin: .zero, size: .init(width: 320, height: 320))
//        redView.borderWidth = 5
        redView.isUserInteractionEnabled = false
        contentView.addSubview(redView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let scale = bounds.size.width / model.gridJson.width
        redView.transform = .init(scaleX: scale, y: scale)
        redView.frame = bounds
        redView.refreshSubviewsFrame()
    }
}

extension CollectionViewCell {
    struct Model: Hashable {
        static func == (lhs: CollectionViewCell.Model, rhs: CollectionViewCell.Model) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        let id = UUID()
        
        let gridJson: GridJson
        
        init(gridJson: GridJson) {
            self.gridJson = gridJson
        }
        
        init(originalJson: String) {
            let dict = try? JSONSerialization.jsonObject(with: originalJson.data(using: .utf8)!) as? [String: Any]
            
            gridJson = GridJson.fromJson(dict ?? [:])
        }
    }
}
