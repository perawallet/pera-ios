//
//  BarButtonItem.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol BarButtonItem {
    
    typealias TitleContent = BarButtonItemTitleContent
    typealias ImageContent = BarButtonItemImageContent
    typealias Size = BarButtonSize
    typealias InteractionHandler = () -> Void
    
    var theme: Theme { get }
    var title: TitleContent? { get }
    var image: ImageContent? { get }
    var size: Size { get }
    var handler: InteractionHandler? { get set }
    
    /// Returns nil if the bar button item cannot be configured as a back/dismiss.
    static func back() -> Self?
    static func dismiss() -> Self?
}

extension BarButtonItem {
    
    var theme: Theme {
        return .light
    }
    
    var title: TitleContent? {
        return nil
    }
    
    var image: ImageContent? {
        return nil
    }
    
    var size: Size {
        return .explicit(CGSize(width: 30.0, height: 30.0))
    }
    
    static func back() -> Self? {
        return nil
    }
    
    static func dismiss() -> Self? {
        return nil
    }
}

struct BarButtonItemTitleContent {
    
    let text: String
    let textColor: UIColor
    let font: UIFont
}

struct BarButtonItemImageContent {
    
    let normal: UIImage
    let highlighted: UIImage?
    let tintColor: UIColor?
    
    init(normal: UIImage, highlighted: UIImage? = nil, tintColor: UIColor? = nil) {
        self.normal = normal
        self.highlighted = highlighted
        self.tintColor = tintColor
    }
}

struct BarButtonCompressedSizeInsets {
    
    let contentInsets: UIEdgeInsets
    let titleInsets: UIEdgeInsets?
    let imageInsets: UIEdgeInsets?
    
    init(contentInsets: UIEdgeInsets = .zero, titleInsets: UIEdgeInsets? = nil, imageInsets: UIEdgeInsets? = nil) {
        self.contentInsets = contentInsets
        self.titleInsets = titleInsets
        self.imageInsets = imageInsets
    }
}

struct BarButtonExpandedSizeHorizontalInsets {
    
    typealias Insets = (left: CGFloat, right: CGFloat)
    
    let contentInsets: Insets
    let titleInsets: Insets?
    let imageInsets: Insets?
    
    init(contentInsets: Insets, titleInsets: Insets? = nil, imageInsets: Insets? = nil) {
        self.contentInsets = contentInsets
        self.titleInsets = titleInsets
        self.imageInsets = imageInsets
    }
}

struct BarButtonExpandedSizeVerticalInsets {
    
    typealias Insets = (top: CGFloat, bottom: CGFloat)
    
    let contentInsets: Insets
    let titleInsets: Insets?
    let imageInsets: Insets?
    
    init(contentInsets: Insets, titleInsets: Insets? = nil, imageInsets: Insets? = nil) {
        self.contentInsets = contentInsets
        self.titleInsets = titleInsets
        self.imageInsets = imageInsets
    }
}

struct BarButtonAlignedContentSize {
    
    typealias Alignment = BarButtonAlignedContentAlignment
    
    let explicitSize: CGSize
    let alignment: Alignment
    let insets: UIEdgeInsets
    
    init(explicitSize: CGSize, alignment: Alignment = .left, insets: UIEdgeInsets = .zero) {
        self.explicitSize = explicitSize
        self.alignment = alignment
        self.insets = insets
    }
}

enum BarButtonExpandedSizeMetric {
    case equal(CGFloat)
    /// DynamicDimension refers to width, parameters reflect left&right insets,
    /// likewise it refers to height, parameters reflect top&bottom insets.
    case dynamicWidth(BarButtonExpandedSizeHorizontalInsets)
    case dynamicHeight(BarButtonExpandedSizeVerticalInsets)
}

enum BarButtonAlignedContentAlignment {
    case top
    case left
    case bottom
    case right
}

enum BarButtonSize {
    case compressed(BarButtonCompressedSizeInsets)
    case expanded(width: BarButtonExpandedSizeMetric, height: BarButtonExpandedSizeMetric)
    case aligned(BarButtonAlignedContentSize)
    case explicit(CGSize)
}

enum Theme {
    case light
    case dark
}
