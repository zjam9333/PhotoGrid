//
//  PresetColors.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/14.
//

import UIKit

struct PresetColors {
    let colors: [UIColor] = ([
        .red, .green, .blue, .cyan, .magenta, .yellow, .brown,
    ] as [UIColor]).map { old in
        return old.modifyHSB(sat: 0.1)
    }
    
    var curr = 0
    
    mutating func next() -> UIColor {
        let color = colors[curr % colors.count]
        curr += 1
        return color
    }
}

private extension UIColor {
    func modifyHSB(hue: CGFloat? = nil, sat: CGFloat? = nil, bri: CGFloat? = nil, alp: CGFloat? = nil) -> UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: hue ?? h, saturation: sat ?? s, brightness: bri ?? b, alpha: alp ?? a)
    }
}
