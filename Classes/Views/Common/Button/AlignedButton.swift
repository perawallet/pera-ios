//
//  AlignedButton.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 24.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AlignedButton: UIButton {
    
    private let style: Style
    
    init(style: Style) {
        self.style = style
        
        super.init(frame: CGRect.zero)
        
        configure()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        if !style.isCenteredHorizontally {
            return
        }
        titleLabel?.textAlignment = .center
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var titleRect = super.titleRect(forContentRect: contentRect)
        
        if image(for: .normal) == nil {
            return titleRect
        }
        
        switch style {
        case .none:
            return titleRect
        case .imageTop(let adjustment),
             .imageLeft(let adjustment),
             .imageBottom(let adjustment),
             .imageRight(let adjustment):
            if style.isCenteredHorizontally {
                titleRect.origin.x = 0.0
                titleRect.size.width = contentRect.width
            } else if case .imageLeft = style {
                titleRect.origin.x =
                    contentRect.width - (titleRect.width + contentEdgeInsets.right).rounded()
            } else if case .imageRight = style {
                titleRect.origin.x = contentEdgeInsets.left
            }
            
            if style.isCenteredVertically {
                let spaceY = contentRect.height - (titleRect.height + contentEdgeInsets.vertical)
                titleRect.origin.y = (spaceY / 2.0).rounded()
            } else if case .imageTop = style {
                titleRect.origin.y =
                    contentRect.height - (titleRect.height + contentEdgeInsets.bottom).rounded()
            } else if case .imageBottom = style {
                titleRect.origin.y = contentEdgeInsets.top
            }
            
            titleRect.origin.x += adjustment?.title.x ?? 0.0
            titleRect.origin.y += adjustment?.title.y ?? 0.0
            
            return titleRect
            
        case .imageLeftTitleCentered(let adjustment):
            titleRect.origin.x += adjustment?.title.x ?? 0.0
            titleRect.origin.y += adjustment?.title.y ?? 0.0
            
            return titleRect
        }
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var imageRect = super.imageRect(forContentRect: contentRect)
        
        if title(for: .normal) == nil {
            return imageRect
        }
        
        switch style {
        case .none:
            return imageRect
        case .imageTop(let adjustment),
             .imageLeft(let adjustment),
             .imageBottom(let adjustment),
             .imageRight(let adjustment):
            
            if style.isCenteredHorizontally {
                let spaceX = contentRect.width - (imageRect.width + contentEdgeInsets.horizontal)
                imageRect.origin.x = (spaceX / 2.0).rounded()
            } else if case .imageLeft = style {
                imageRect.origin.x = contentEdgeInsets.left
            } else if case .imageRight = style {
                imageRect.origin.x =
                    contentRect.width - (imageRect.width + contentEdgeInsets.right).rounded()
            }
            
            if style.isCenteredVertically {
                let spaceY = contentRect.height - (imageRect.height + contentEdgeInsets.vertical)
                imageRect.origin.y = (spaceY / 2.0).rounded()
            } else if case .imageTop = style {
                imageRect.origin.y = contentEdgeInsets.top
            } else if case .imageBottom = style {
                imageRect.origin.y =
                    contentRect.height - (imageRect.height + contentEdgeInsets.bottom).rounded()
            }
            
            imageRect.origin.x += adjustment?.image.x ?? 0.0
            imageRect.origin.y += adjustment?.image.y ?? 0.0
            
            return imageRect
        case .imageLeftTitleCentered(let adjustment):
            imageRect.origin.x = contentEdgeInsets.left
            
            let spaceY = contentRect.height - (imageRect.height + contentEdgeInsets.vertical)
            imageRect.origin.y = (spaceY / 2.0).rounded()
            
            imageRect.origin.x += adjustment?.image.x ?? 0.0
            imageRect.origin.y += adjustment?.image.y ?? 0.0
            
            return imageRect
        }
    }
}

extension AlignedButton {
    
    typealias StylePositionAdjustment = (image: CGPoint, title: CGPoint)?
    
    enum Style {
        case none
        case imageTop(StylePositionAdjustment)
        case imageLeft(StylePositionAdjustment)
        case imageBottom(StylePositionAdjustment)
        case imageRight(StylePositionAdjustment)
        case imageLeftTitleCentered(StylePositionAdjustment)
    }
}

extension AlignedButton.Style {
    
    var isCenteredHorizontally: Bool {
        switch self {
        case .imageTop, .imageBottom:
            return true
        default:
            return false
        }
    }
    
    var isCenteredVertically: Bool {
        switch self {
        case .imageLeft, .imageRight:
            return true
        default:
            return false
        }
    }
}

extension AlignedButton.Style: Equatable {
    
    static func == (lhs: AlignedButton.Style, rhs: AlignedButton.Style) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none),
             (.imageTop, .imageTop),
             (.imageLeft, .imageLeft),
             (.imageBottom, .imageBottom),
             (.imageRight, .imageRight):
            return true
        default:
            return false
        }
    }
}
