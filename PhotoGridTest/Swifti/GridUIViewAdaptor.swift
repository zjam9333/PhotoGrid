//
//  GridUIViewAdaptor.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/3/24.
//

import SwiftUI

struct GridUIViewAdaptor: UIViewRepresentable {
    struct Model {
        var version = UUID()
        var json: GridJson
        var images: [UIImage]
        var borderColor: UIColor
    }
    
    var model: Model
    
    func makeUIView(context: Context) -> PhotoGridView {
        let uiView = PhotoGridView(json: model.json)
        return uiView
    }
    
    func updateUIView(_ uiView: PhotoGridView, context: Context) {
        uiView.updateGrid(json: model.json)
        uiView.contentGetter = { i in
            guard i < model.images.count else {
                return nil
            }
            return model.images[i]
        }
        uiView.borderColor = model.borderColor
        uiView.refreshSubviewsFrame()
        uiView.refreshSubviewsContent()
    }
    
    typealias UIViewType = PhotoGridView
}
