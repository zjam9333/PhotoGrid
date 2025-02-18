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
    
    var item: GridDivider!
    var redView: PhotoGridView!
    var lines: [Int: GridItem] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bounds = CGRect(origin: .zero, size: .init(width: 320, height: 320))
        
        let line0 = GGLine(x1: 0, y1: bounds.size.height / 3, x2: bounds.size.width, y2: bounds.size.height / 4)
        item = GridDivider(line: line0)
        
        let line1 = GGLine(x1: bounds.size.width / 3, y1: 0, x2: bounds.size.width / 3 - 40, y2: bounds.size.height).reverted()
        item.left = GridDivider(line: line1)
        //
        let line2 = GGLine(x1: bounds.size.width / 3 + 40, y1: 0, x2: bounds.size.width / 3 + 40 + 40, y2: bounds.size.height).reverted()
        item.right = GridDivider(line: line2)
        
        let line3 = GGLine(x1: 0 + 40, y1: bounds.size.height / 3 * 2, x2: bounds.size.width, y2: bounds.size.height / 3 * 1.5)
        item.right.asDivider?.right = GridDivider(line: line3)
        
        lines = [
            0: item,
            1: item.left,
            2: item.right,
            3: item.right.asDivider!.right,
        ]
        
        print("hello world")
        
        redView = PhotoGridView(item: item)
        redView.borderWidth = 5
        view.addSubview(redView)
        
        redView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(100)
            make.width.height.equalTo(320)
        }
        
        DispatchQueue.main.async { [self] in
            redView.refreshSubviewsFrame()
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        guard let li = lines[sender.tag] as? GridDivider else {
            return
        }
        let p1 = li.line.p1
        let p2 = li.line.p2
        let delDx = abs(p1.x - p2.x)
        let delDy = abs(p1.y - p2.y)
        if (delDx < delDy) {
            li.offset.dx = .init(sender.value)
        } else {
            li.offset.dy = .init(sender.value)
        }
        redView.refreshSubviewsFrame()
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        redView.borderWidth = sender.value
        redView.refreshSubviewsFrame()
    }
}

