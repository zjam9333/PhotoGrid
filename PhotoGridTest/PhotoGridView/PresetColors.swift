//
//  PresetColors.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/2/14.
//

import UIKit

struct PresetColors {
    let colors: [UIColor] = [
        .red, .green, .blue, .cyan, .magenta, .yellow, .black,
    ]
    
    var curr = 0
    
    mutating func next() -> UIColor {
        let color = colors[curr % colors.count]
        curr += 1
        return color
    }
}
