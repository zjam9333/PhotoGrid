//
//  ModifySelfProtocol.swift
//  PhotoGridTest
//
//  Created by zhangjingjian on 2025/3/20.
//

import UIKit
import Combine

public protocol ModifySelfProtocol {
}

extension UIView: ModifySelfProtocol {
}

public extension ModifySelfProtocol where Self: UIView {
    func property<Value, C>(_ keyPath: WritableKeyPath<Self, Value>, binding: Published<Value>.Publisher, storeIn set: inout C) -> Self where C : RangeReplaceableCollection, C.Element == AnyCancellable {
        binding.receive(on: DispatchQueue.main).sink { [weak self] val in
            self?[keyPath: keyPath] = val
        }.store(in: &set)
        return self
    }
    
    func property<Value>(_ keyPath: WritableKeyPath<Self, Value>, value newValue: Value) -> Self {
        // self[keyPath: keyPath] = newValue
        // 收到警告？？？Cannot assign through subscript: 'self' is immutable
        var weakself = self as Self?
        weakself?[keyPath: keyPath] = newValue
        return self
    }
    
    func propertyModifing(action: (Self) -> Void) -> Self {
        action(self)
        return self
    }
}
