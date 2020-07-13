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
        switch kind {
        case .save:
            return BarButtonItemTitleContent(
                text: "title-save".localized,
                textColor: SharedColors.primaryText,
                font: UIFont.font(withWeight: .bold(size: 12.0))
            )
        case .done:
            return BarButtonItemTitleContent(
                text: "title-done".localized,
                textColor: SharedColors.tertiaryText,
                font: UIFont.font(withWeight: .semiBold(size: 16.0))
            )
        case .edit:
            return BarButtonItemTitleContent(
                text: "title-edit".localized,
                textColor: SharedColors.primaryText,
                font: UIFont.font(withWeight: .semiBold(size: 16.0))
            )
        default:
            return nil
        }
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
        case .add:
            if let icon = img("img-accounts-add") {
                return ImageContent(normal: icon)
            }
            return nil
        case .close:
            if let icon = img("icon-close") {
                return ImageContent(normal: icon)
            }
            return nil
        case .save:
            return nil
        case .qr:
            if let icon = img("icon-qr-bar-button") {
                return ImageContent(normal: icon)
            }
            return nil
        case .info:
            if let icon = img("icon-info-green") {
                return ImageContent(normal: icon)
            }
            return nil
        case .done:
            return nil
        case .edit:
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
        case .add:
            return .explicit(CGSize(width: 44.0, height: 44.0))
        case .close:
            return .explicit(CGSize(width: 44.0, height: 44.0))
        case .qr:
            return .explicit(CGSize(width: 44.0, height: 44.0))
        case .save:
            return .expanded(
                width: .dynamicWidth(BarButtonExpandedSizeHorizontalInsets(
                    contentInsets: (left: 0.0, right: 0.0),
                    titleInsets: (left: 4.0, right: -4.0))
                ),
                height: .equal(44.0)
            )
        case .info:
            return .explicit(CGSize(width: 44.0, height: 44.0))
        case .done:
            return .expanded(
                width: .dynamicWidth(BarButtonExpandedSizeHorizontalInsets(
                    contentInsets: (left: 0.0, right: 0.0),
                    titleInsets: (left: 4.0, right: -4.0))
                ),
                height: .equal(44.0)
            )
        case .edit:
            return .expanded(
                width: .dynamicWidth(BarButtonExpandedSizeHorizontalInsets(
                    contentInsets: (left: 0.0, right: 0.0),
                    titleInsets: (left: 4.0, right: -4.0))
                ),
                height: .equal(44.0)
            )
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
        case options
        case add
        case close
        case save
        case qr
        case done
        case edit
        case info
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
