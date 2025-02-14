//
//  ViewController.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/13.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    @IBAction func buttonTap(_ sender: Any) {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            let b = view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
            print("drawHierarchy", b)
        }
        print("image", image)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hello world")
        
        let redView = PhotoGridView()
        view.addSubview(redView)
        
        redView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.width.height.equalTo(320)
        }
        
        DispatchQueue.main.async {
            redView.refreshSubviewsFrame()
        }
    }
}

