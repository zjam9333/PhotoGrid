//
//  ViewController.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/13.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    @IBAction func exportJson(_ sender: Any?) {
        let json = gridJson.toJson()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]) else {
            return
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        print("导出的json", jsonString)
    }
    
    @IBAction func captureImage(_ sender: Any) {
        let renderer = UIGraphicsImageRenderer(size: redView.bounds.size)
        let image = renderer.image { [weak self] ctx in
            guard let view = self?.redView else {
                return
            }
            let b = view.snapshotView.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
            print("drawHierarchy", b)
        }
        print("image", image)
    }
    
    var gridJson: GridJson!
    var redView: PhotoGridView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // line的方向会影响left和right的位置
        // line的x1y1为下，x2y2为上，切出来的左右两份分别为left和right
        let json: String = """
{
    "width": 320,
    "height": 320,
    "item": {
        "type": "line",
        "key": 0,
        "line": {
            "x1": 0,
            "y1": 100,
            "x2": 300,
            "y2": 80
        },
        "offset": {
            "dx": 30,
            "dy": 30
        },
        "left": {
            "type": "polygon",
            "key": 0,
            "controllableKeys": [
                0
            ]
        },
        "right": {
            "type": "line",
            "key": 1,
            "line": {
                "x2": 160,
                "y2": 0,
                "x1": 100,
                "y1": 320
            },
            "left": {
                "type": "polygon",
                "key": 1,
                "controllableKeys": [
                    0,
                    1
                ]
            },
            "right": {
                "type": "line",
                "key": 2,
                "line": {
                    "x1": 0,
                    "y1": 200,
                    "x2": 320,
                    "y2": 230
                },
                "left": {
                    "type": "polygon",
                    "key": 2,
                    "controllableKeys": [
                        0,
                        1,
                        2
                    ]
                },
                "right": {
                    "type": "polygon",
                    "key": 3,
                    "controllableKeys": [
                        1,
                        2
                    ]
                }
            }
        }
    }
}
"""
        let dict = try? JSONSerialization.jsonObject(with: json.data(using: .utf8)!) as? [String: Any]
        
        gridJson = GridJson.fromJson(dict ?? [:])
        
        print("hello world")
        
        redView = PhotoGridView(item: gridJson.item)
        redView.borderWidth = 5
        view.addSubview(redView)
        
        redView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(100)
            make.width.equalTo(gridJson.width)
            make.height.equalTo(gridJson.height)
        }
//        redView.transform = .init(scaleX: 0.5, y: 0.5)
        
        DispatchQueue.main.async { [self] in
            redView.refreshSubviewsFrame()
        }
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        redView.borderWidth = sender.value
        redView.refreshSubviewsFrame()
    }
}

