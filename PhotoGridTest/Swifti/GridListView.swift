//
//  GridListView.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/3/24.
//

import SwiftUI

struct GridListView: View {
    
    class Model: Identifiable, Equatable, Hashable {
        
        static func == (l: Model, r: Model) -> Bool {
            return l.id == r.id
        }
        
        let id = UUID()
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        var json: GridJson
        
        init(json: GridJson) {
            self.json = json
        }
        
        init(originalJson: String) {
            let dict = try? JSONSerialization.jsonObject(with: originalJson.data(using: .utf8)!) as? [String: Any]
            
            json = GridJson.fromJson(dict ?? [:])
        }
    }
    
    @State var gridModel: GridUIViewAdaptor.Model = .init(json: .fromJson([:]), images: [], borderColor: .blue)
    @State var models: [Model] = []
    
    @State var showingImagePicker = false
    @State private var viewDidLoad = false
    
    var body: some View {
        
        ScrollView {
            cells
        }
        .navigationTitle("Grid List")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Model.self) { model in
            let _ = (gridModel.json = model.json)
            GridDetailView(model: $gridModel)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    showingImagePicker = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    reload()
                } label: {
                    Image(systemName: "arrow.trianglehead.clockwise")
                }
            }
        }
        .fullScreenCover(isPresented: $showingImagePicker) {
            ImagePicker(images: $gridModel.images)
        }.onAppear {
            
            if viewDidLoad == false {
                viewDidLoad = true
                reload()
            }
        }
    }
    
    @ViewBuilder var cells: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { proxy in
                let width = proxy.size.width
                let mar: CGFloat = 10
                let perWid = max(0, (width - (mar * 2)) / 3)
                ForEach(models) { model in
                    let ind = models.firstIndex(of: model) ?? 0
                    
                    NavigationLink(value: model) {
                        let gM = GridUIViewAdaptor.Model(json: model.json, images: gridModel.images, borderColor: gridModel.borderColor)
                        GridUIViewAdaptor(model: gM)
                            .frame(width: model.json.width, height: model.json.height)
                            .scaleEffect(CGSize(width: perWid / model.json.width, height: perWid / model.json.height))
                            .frame(width: perWid, height: perWid)
                            .allowsHitTesting(false)
                    }
                    .offset(x: CGFloat(ind % 3) * (perWid + mar), y: CGFloat(ind / 3) * (perWid + mar))
                }
            }.padding(10)
        }
    }
    
    func reload() {
        let gridJsons: [Model] = [
            .init(originalJson: jsonOnlyOne),
            .init(originalJson: json0),
            .init(originalJson: json1),
            .init(originalJson: json2),
            .init(originalJson: json3),
            .init(originalJson: json4),
            .init(originalJson: json5),
            .init(originalJson: json),
        ]
        models = gridJsons
        gridModel = .init(json: GridJson(width: 300, height: 300, item: .random()), images: [], borderColor: .black)
    }
}

#Preview {
    NavigationStack {
        GridListView()
    }
}

import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            let group = DispatchGroup()
            var images: [UIImage] = []
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    defer {
                        group.leave()
                    }
                    if let image = image as? UIImage {
                        images.append(image)
                    }
                }
            }
            group.notify(queue: .main) { [weak self] in
                self?.parent.images = images
            }
        }
    }
    
    @Binding var images: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.selectionLimit = 4
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
