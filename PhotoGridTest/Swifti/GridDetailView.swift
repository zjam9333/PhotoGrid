//
//  GridDetailView.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/3/21.
//

import SwiftUI
import QuickLook
import Photos

extension UIImage: @retroactive Identifiable {
}

struct GridDetailView: View {
    
    class Refs: ObservableObject {
        var gridUIView: PhotoGridView? = nil
        @Published var exportJsonFile: URL?
        @Published var snapshotImage: UIImage?
        @Published var selectedPolygon: GridItem.Key?
    }
    
    @Binding var model: GridUIViewAdaptor.Model
    
    @State var showQuickLook = false
    @State var showColorPicker = false
    @State var showImagePicker = false
    
    @StateObject var refs: Refs = Refs()
    
    var body: some View {
        let width: CGFloat = 360
        VStack {
            Spacer().frame(height: 40)
            
            GridUIViewAdaptor(model: model) { gridv in
                refs.gridUIView = gridv
            } onPolygonSelect: { key in
                refs.selectedPolygon = key
            }
            .frame(width: model.json.width, height: model.json.height)
            .scaleEffect(CGSize(width: width / model.json.width, height: width / model.json.height))
            .frame(width: width, height: width)
            
            Spacer().frame(height: 40)
            
            VStack(alignment: .leading, spacing: 10) {
                
                Button {
                    do {
                        let json = model.json.toJson()
                        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
                        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                            return
                        }
                        print("导出的json", jsonString)
                        let filePath = NSTemporaryDirectory() + "layout.json"
                        let fileURL = URL(fileURLWithPath: filePath)
                        try jsonData.write(to: fileURL, options: .atomic)
                        refs.exportJsonFile = fileURL
                    } catch {
                        
                    }
                } label: {
                    Text("导出Json看看")
                }
                .quickLookPreview($refs.exportJsonFile)
                Spacer().frame(height: 10)
                
                Button {
                    guard let redView = refs.gridUIView?.snapshotView else {
                        return
                    }
                    let renderer = UIGraphicsImageRenderer(size: redView.bounds.size)
                    let image = renderer.image { ctx in
                        let b = redView.drawHierarchy(in: redView.bounds, afterScreenUpdates: false)
                        print("drawHierarchy", b)
                    }
                    refs.snapshotImage = image
                    print("image", image)
                } label: {
                    Text("截图打断点看看")
                }
                .sheet(item: $refs.snapshotImage) { image in
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 300, height: 300)
                        Spacer().frame(height: 30)
                        Button {
                            Task {
                                try? await PHPhotoLibrary.shared().performChanges {
                                    let request = PHAssetCreationRequest.forAsset()
                                    request.addResource(with: .photo, data: image.pngData()!, options: nil)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("保存")
                            }
                        }
                    }
                }
                Spacer().frame(height: 10)
                
                HStack {
                    Text("边框")
                    Slider(value: Binding<CGFloat>(get: {
                        return model.json.borderWidth
                    }, set: { f in
                        model.json.borderWidth = f
                        model.version = UUID()
                    }), in: 0...40)
                    .frame(width: 120)
                }
                
                HStack {
                    Text("线粗")
                    Slider(value: Binding<CGFloat>(get: {
                        return model.json.lineWidth
                    }, set: { f in
                        model.json.lineWidth = f
                        model.version = UUID()
                    }), in: 0...40)
                    .frame(width: 120)
                }
                
                HStack {
                    Text("圆角")
                    Slider(value: Binding<CGFloat>(get: {
                        return model.json.cornerRadius
                    }, set: { f in
                        model.json.cornerRadius = f
                        model.version = UUID()
                    }), in: 0...40)
                    .frame(width: 120)
                }
                
                HStack {
                    Text("颜色")
                        
                    ColorPicker(selection: .init(get: {
                        return Color(model.borderColor)
                    }, set: { color in
                        guard let cgC = color.cgColor else {
                            return
                        }
                        model.borderColor = UIColor(cgColor: cgC)
                        model.version = UUID()
                    }), supportsOpacity: true) {
                        Rectangle()
                            .fill(Color(uiColor: model.borderColor))
                            .frame(height: 30)
                    }.frame(width: 120)
                }
            }
            
            Spacer()
        }
        .navigationTitle("Grid Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let key = refs.selectedPolygon {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showImagePicker = true
                    } label: {
                        Text("换图")
                    }
                    .fullScreenCover(isPresented: $showImagePicker) {
                        ImagePicker(selectionLimit: 1) { imgs in
                            guard let fir = imgs.first else {
                                return
                            }
                            model.images[key] = fir
                            model.version = UUID()
                        }
                    }
                }
            }
        }
    }
}



#Preview {
    
    @Previewable @State var raw = GridUIViewAdaptor.Model(
        json: {
            let _json0: String = """
{
    "width": 300,
    "height": 300,
    "borderWidth": 10,
    "lineWidth": 10,
    "item": {
        "type": "line",
        "key": 0,
        "line": {
            "x1": 0,
            "y1": 150,
            "x2": 300,
            "y2": 150
        },
        "offset": {
            "dx": 0,
            "dy": 0
        },
        "left": {
            "type": "polygon",
            "key": 0,
            "controllableKeys": [
                0
            ]
        },
        "right": {
            "type": "polygon",
            "key": 1,
            "controllableKeys": [
                0
            ]
        }
    }
}
"""
            
            let _json = GridJson.fromJson(try! JSONSerialization.jsonObject(with: _json0.data(using: .utf8)!) as! [String: Any])
            return _json
        }(),
        images: [:],
        borderColor: .systemPink
    )
    NavigationStack {
        GridDetailView(model: $raw)
    }
}
