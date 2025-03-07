//
//  DragControl.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/27.
//

import UIKit

class DragControl: UIView {
    var onDrag: ((UITouch) -> Void)?
    
    let imageView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.contentMode = .scaleToFill
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(30)
            make.height.equalTo(10)
        }
        imageView.layer.cornerRadius = 5
        imageView.backgroundColor = .cyan
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
