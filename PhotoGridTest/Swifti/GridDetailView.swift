//
//  GridDetailView.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/3/21.
//

import SwiftUI

struct GridDetailView: View {
    
    @Binding var model: GridUIViewAdaptor.Model
    
    var body: some View {
        let width: CGFloat = 300
        VStack {
            Spacer().frame(height: 40)
            GridUIViewAdaptor(model: model)
                .frame(width: model.json.width, height: model.json.height)
                .scaleEffect(CGSize(width: width / model.json.width, height: width / model.json.height))
                .frame(width: width, height: width)
            
            Spacer().frame(height: 40)
            
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
            
            Spacer()
        }
        .navigationTitle("Grid Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

import QuickLook

struct QuickLookRepresent: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> QLPreviewController {
        let vc = QLPreviewController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = QLPreviewController
    
    
}

#Preview {
    
    
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
    var raw = GridUIViewAdaptor.Model(json: _json, images: [], borderColor: .black)
    NavigationStack {
        GridDetailView(model: .init(get: {
            raw
        }, set: { m in
            raw = m
        }))
    }
}
