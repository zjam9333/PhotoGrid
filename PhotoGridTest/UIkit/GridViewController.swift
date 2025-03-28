//
//  DetailViewController.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/3/3.
//

import UIKit
import QuickLook
import Combine

class GridViewController: UIViewController {
    
    @objc func exportJson(_ sender: Any?) {
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
            navigationController?.pushViewController(previewVC, animated: true)
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
    
    @objc func captureImage(_ sender: Any) {
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
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        switch sender.tag {
        case 1:
            redView.json.borderWidth = CGFloat(sender.value)
        case 2:
            redView.json.lineWidth = CGFloat(sender.value)
        case 3:
            redView.json.cornerRadius = CGFloat(sender.value)
        default:
            return
        }
        redView.refreshSubviewsFrame()
    }
    
    @objc func selectColor(_ sender: Any) {
        let colorPick = UIColorPickerViewController()
        colorPick.delegate = self
        present(colorPick, animated: true)
    }
    
    private var allSubscriptions: [AnyCancellable] = []
    
    private var jsonURL: URL!
    private var redView: PhotoGridView!
    private var snapshowImageView: UIImageView!
    
    var gridJson: GridJson
    var selectedImages: [UIImage]
    
    @Published private var borderColor: UIColor? = .red
    
    init(gridJson: GridJson, selectedImages: [UIImage]) {
        self.gridJson = gridJson
        self.selectedImages = selectedImages
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.navigationItem.title = "Grid Detail"
        
        redView = PhotoGridView(json: gridJson).property(\.borderColor, binding: $borderColor, storeIn: &allSubscriptions)
        
        view.addSubview(redView)
        
        redView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
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
        
        let stack = UIStackView(arrangedSubviews: [
            {
                let b = UIButton(type: .system)
                b.setTitle("导出JSON", for: .normal)
                b.addTarget(self, action: #selector(exportJson), for: .touchUpInside)
                return b
            }(),
            {
                let b = UIButton(type: .system)
                b.setTitle("截图打断点看看", for: .normal)
                b.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
                return b
            }(),
            {
                let stack = UIStackView(arrangedSubviews: [
                    {
                        let b = UILabel()
                        b.text = "边框"
                        b.textColor = .black
                        return b
                    }(),
                    {
                        let b = UISlider()
                        b.tag = 1
                        b.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
                        b.minimumValue = 0
                        b.maximumValue = 50
                        b.value = Float(redView.json.borderWidth)
                        b.snp.makeConstraints { make in
                            make.width.equalTo(120)
                        }
                        return b
                    }(),
                ])
                stack.axis = .horizontal
                stack.spacing = 10
                return stack
            }(),
            {
                let stack = UIStackView(arrangedSubviews: [
                    {
                        let b = UILabel()
                        b.text = "线粗"
                        b.textColor = .black
                        return b
                    }(),
                    {
                        let b = UISlider()
                        b.tag = 2
                        b.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
                        b.minimumValue = 0
                        b.maximumValue = 50
                        b.value = Float(redView.json.lineWidth)
                        b.snp.makeConstraints { make in
                            make.width.equalTo(120)
                        }
                        return b
                    }(),
                ])
                stack.axis = .horizontal
                stack.spacing = 10
                return stack
            }(),
            {
                let stack = UIStackView(arrangedSubviews: [
                    {
                        let b = UILabel()
                        b.text = "圆角"
                        b.textColor = .black
                        return b
                    }(),
                    {
                        let b = UISlider()
                        b.tag = 3
                        b.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
                        b.minimumValue = 0
                        b.maximumValue = 50
                        b.value = Float(redView.json.cornerRadius)
                        b.snp.makeConstraints { make in
                            make.width.equalTo(120)
                        }
                        return b
                    }(),
                ])
                stack.axis = .horizontal
                stack.spacing = 10
                return stack
            }(),
            {
                let stack = UIStackView(arrangedSubviews: [
                    {
                        let b = UILabel()
                        b.text = "颜色"
                        b.textColor = .black
                        return b
                    }(),
                    {
                        let b = UIControl().property(\.backgroundColor, binding: $borderColor, storeIn: &allSubscriptions)
                        b.addTarget(self, action: #selector(selectColor), for: .touchUpInside)
                        b.snp.makeConstraints { make in
                            make.width.equalTo(120)
                            make.height.equalTo(30)
                        }
                        return b
                    }(),
                ])
                stack.axis = .horizontal
                stack.spacing = 10
                return stack
            }(),
        ])
        stack.axis = .vertical
        stack.spacing = 10
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(redView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
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

extension GridViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        borderColor = color
    }
}
