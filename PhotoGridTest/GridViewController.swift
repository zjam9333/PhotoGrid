//
//  DetailViewController.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/3/3.
//

import UIKit

class GridViewController: UIViewController {
    
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
    
    private var redView: PhotoGridView!
    var gridJson: GridJson!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Grid Detail"
        
        redView = PhotoGridView(item: gridJson.item)
//        redView.borderWidth = 5
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
