//
//  DragControl.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/27.
//

import UIKit

class DragControl: UIView {
    var onDrag: ((UITouch) -> Void)?
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.transform = .init(scaleX: 0.8, y: 0.8)
        imageView.contentMode = .scaleToFill
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "mount.fill")?.withRenderingMode(.alwaysTemplate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let first = touches.first else {
            return
        }
        onDrag?(first)
    }
}
