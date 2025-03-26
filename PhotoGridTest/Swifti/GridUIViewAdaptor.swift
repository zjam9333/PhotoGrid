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
        var images: [Int: UIImage]
        var borderColor: UIColor
    }
    
    var model: Model
    var viewInstanceOnCreated: ((UIViewType) -> Void)?
    var onPolygonSelect: ((GridPolygon.Key?) -> Void)?
    
    func makeUIView(context: Context) -> PhotoGridView {
        let uiView = PhotoGridView(json: model.json)
        viewInstanceOnCreated?(uiView)
        return uiView
    }
    
    func updateUIView(_ uiView: PhotoGridView, context: Context) {
        if (uiView.json !== model.json) {
            uiView.updateGrid(json: model.json)
        }
        uiView.contentGetter = { i in
            return model.images[i]
        }
        uiView.onPolygonSelect = { i in
            onPolygonSelect?(i)
        }
        uiView.borderColor = model.borderColor
        uiView.refreshSubviewsFrame()
        uiView.refreshSubviewsContent()
    }
    
    typealias UIViewType = PhotoGridView
}
