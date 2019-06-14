//
//  ALGBarButtonItem.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

struct ALGBarButtonItem: BarButtonItem {
    
    var handler: EmptyHandler?
    
    var title: TitleContent? {
        return nil
    }
    
    var image: ImageContent? {
        switch kind {
        case .back:
            if let icon = img("icon-back") {
                return ImageContent(normal: icon)
            }
            return nil
        case .options:
            if let icon = img("icon-options") {
                return ImageContent(normal: icon)
            }
            return nil
        case .menu:
            if let icon = img("icon-menu") {
                return ImageContent(normal: icon)
            }
            return nil
        case .add:
            if let icon = img("icon-add") {
                return ImageContent(normal: icon)
            }
            return nil
        case .share:
            if let icon = img("icon-share-black") {
                return ImageContent(normal: icon)
            }
            return nil
            
        case .close:
            if let icon = img("icon-close") {
                return ImageContent(normal: icon)
            }
            return nil
            
        case .removeNode:
            if let icon = img("icon-server-remove") {
                return ImageContent(normal: icon)
            }
            return nil
        case .balance:
            if let icon = img("icon-balance") {
                return ImageContent(normal: icon)
            }
            return nil
        }
    }
    
    var size: ALGBarButtonItem.Size {
        switch kind {
        case .back:
            return .compressed(
                BarButtonCompressedSizeInsets(contentInsets: UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0))
            )
        case .options:
            return .expanded(
                width: .dynamicWidth(BarButtonExpandedSizeHorizontalInsets(contentInsets: (left: 4.0, right: 4.0))),
                height: .equal(44.0)
            )
        case .menu:
            return .compressed(
                BarButtonCompressedSizeInsets(contentInsets: UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0))
            )
        case .add:
            return .explicit(CGSize(width: 44.0, height: 44.0))
        case .share:
            return .explicit(CGSize(width: 44.0, height: 44.0))
        case .close:
            return .explicit(CGSize(width: 44.0, height: 44.0))
        case .removeNode:
            return .explicit(CGSize(width: 44.0, height: 44.0))
        case .balance:
            return .explicit(CGSize(width: 44.0, height: 44.0))
        }
    }
    
    let kind: Kind
    
    init(kind: Kind, handler: EmptyHandler? = nil) {
        
        self.kind = kind
        self.handler = handler
    }
    
    static func back() -> ALGBarButtonItem? {
        return ALGBarButtonItem(kind: .back)
    }
}

extension ALGBarButtonItem {
    
    enum Kind: Hashable {
        case back
        case menu
        case options
        case add
        case share
        case close
        case removeNode
        case balance
    }
}

extension ALGBarButtonItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(kind.hashValue)
    }
    
    static func == (lhs: ALGBarButtonItem, rhs: ALGBarButtonItem) -> Bool {
        return lhs.kind == rhs.kind
    }
}
