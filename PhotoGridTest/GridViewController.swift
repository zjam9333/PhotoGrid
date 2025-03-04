//
//  DetailViewController.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/3/3.
//

import UIKit
import QuickLook

class GridViewController: UIViewController {
    
    @IBAction func exportJson(_ sender: Any?) {
        let json = gridJson.toJson()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return
            }
            print("导出的json", jsonString)
            let filePath = NSTemporaryDirectory() + "layout.json"
            let fileURL = URL(fileURLWithPath: filePath)
            try jsonData.write(to: fileURL, options: .atomic)
            self.jsonURL = fileURL
            let previewVC = QLPreviewController()
            previewVC.dataSource = self
            present(previewVC, animated: true)
//            let avc = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
//            avc.excludedActivityTypes = []
//            avc.completionWithItemsHandler = { [unowned avc] type, completed, returnedItems, error in
//                avc.dismiss(animated: true) {
//                    print("[dismiss activity]", type ?? "nil", error ?? "nil")
//                }
//            }
//            present(avc, animated: true, completion: nil)
        } catch {
            print("some error \(error)")
        }
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
        snapshowImageView.image = image
    }
    
    private var jsonURL: URL!
    private var redView: PhotoGridView!
    private var snapshowImageView: UIImageView!
    var gridJson: GridJson!
    var selectedImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Grid Detail"
        
        redView = PhotoGridView(json: gridJson)
        redView.borderWidth = 5
        view.addSubview(redView)
        
        redView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(100)
            make.width.equalTo(gridJson.width)
            make.height.equalTo(gridJson.height)
        }
        redView.contentGetter = { [weak self] key in
            if self?.selectedImages.indices.contains(key) == true {
                return self?.selectedImages[key]
            }
            return nil
        }
        
        DispatchQueue.main.async { [self] in
            redView.refreshSubviewsFrame()
            redView.refreshSubviewsContent()
        }
        
        snapshowImageView = UIImageView()
        view.addSubview(snapshowImageView)
        snapshowImageView.snp.makeConstraints { make in
            make.bottom.equalTo(-20)
            make.left.equalTo(20)
            make.width.height.equalTo(100)
        }
    }
    
    @IBAction func stepperValueChanged(_ sender: UISlider) {
        redView.borderWidth = CGFloat(sender.value)
        redView.refreshSubviewsFrame()
    }
}
extension GridViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
        jsonURL as QLPreviewItem
    }
}
