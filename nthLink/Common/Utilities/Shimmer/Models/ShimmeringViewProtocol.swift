//
//  ShimmeringViewProtocol.swift
//  UIView-Shimmer
//
//  
//

import UIKit

struct Key {
    static let shimmer = "Key.ShimmerLayer"
    static let template = "Key.TemplateLayer"
}


public protocol ShimmeringViewProtocol where Self: UIView {
    var shimmeringAnimatedItems: [UIView] { get }
    var excludedItems: Set<UIView> { get }
}

extension ShimmeringViewProtocol {
    public var shimmeringAnimatedItems: [UIView] { [self] }
    public var excludedItems: Set<UIView> { [] }
}
