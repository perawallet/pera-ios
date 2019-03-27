//
//  TabBar.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol TabBarDelegate: class {
    func tabBar(_ view: TabBar, didSelect item: TabBar.Item)
}

class TabBar: BaseView {
    
    // MARK: - Configurations
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        var defaultHeight: CGFloat {
            if let safeAreaBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
                return 50.0 + safeAreaBottom
            }
            
            return 50.0
        }
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: TabBarDelegate?
    
    // MARK: - Components
    
    var buttons: [UIButton]? {
        return contentView.arrangedSubviews as? [UIButton]
    }
    
    private lazy var contentView = UIStackView()
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = SharedColors.warmWhite
        
        setupContentStackViewLayout()
    }
    
    // MARK: - Layout
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: layout.current.defaultHeight)
    }
    
    private func setupContentStackViewLayout() {
        contentView.distribution = .fillEqually
        contentView.axis = .horizontal
        contentView.layoutMargins = UIEdgeInsets(top: 8.0, left: 0, bottom: 0, right: 0)
        contentView.isLayoutMarginsRelativeArrangement = true
        
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupLayout(with items: [TabBar.Item]) {
        items.forEach { anItem in
            let aButton = TabBar.Button(with: anItem)
            
            aButton.addTarget(
                self,
                action: #selector(didTapButton(_:)),
                for: .touchUpInside
            )
            
            contentView.addArrangedSubview(aButton)
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapButton(_ button: TabBar.Button) {
        delegate?.tabBar(self, didSelect: button.item)
    }
    
    // MARK: - Updates
    
    func select(_ item: TabBar.Item) {
        buttons?.forEach { aButton in
            guard let tabBarButton = aButton as? TabBar.Button else {
                return
            }
            
            if tabBarButton.item == item {
                tabBarButton.set(selected: true)
            } else {
                tabBarButton.set(selected: false)
            }
        }
    }
}

extension TabBar {
    private class Button: AlignedButton {
        let item: TabBar.Item
        
        private let normalColor = SharedColors.darkGray
        private let selectedColor = SharedColors.black
        
        init(with item: TabBar.Item) {
            self.item = item
            
            let positions: StylePositionAdjustment = (
                image: CGPoint(x: 0.0, y: 5.0),
                title: CGPoint(x: 0.0, y: 0.0)
            )
            
            super.init(style: .imageTop(positions))
            
            setTitle(item.specs.title, for: .normal)
            setTitle(item.specs.title, for: .selected)
            
            setTitleColor(normalColor, for: .selected)
            setTitleColor(selectedColor, for: .selected)
            
            setImage(item.specs.normalImage, for: .normal)
            setImage(item.specs.selectedImage, for: .selected)
            
            guard let title = item.specs.title else {
                return
            }
            
            let normalAttributedTitle = title.attributed(
                [
                    .textColor(normalColor),
                    .font(UIFont.font(.montserrat, withWeight: .semiBold(size: 10.0))),
                    .lineSpacing(0.95)
                ]
            )
            
            setAttributedTitle(normalAttributedTitle, for: .normal)
            
            let selectedAttributedTitle = title.attributed(
                [
                    .textColor(selectedColor),
                    .font(UIFont.font(.montserrat, withWeight: .semiBold(size: 10.0))),
                    .lineSpacing(0.95)
                ]
            )
            
            setAttributedTitle(selectedAttributedTitle, for: .selected)
            
            set(selected: false)
        }
        
        func set(selected: Bool) {
            isSelected = selected
        }
    }
}

extension TabBar {
    typealias Specs = (title: String?, normalImage: UIImage?, selectedImage: UIImage?)
    
    enum Item: Int {
        case accounts = 0
        case history = 1
        case contacts = 2
        case settings = 3
        
        var specs: Specs {
            switch self {
            case .accounts:
                return (
                    title: "tabbar-item-accounts".localized,
                    normalImage: img("tabbar-icon-accounts"),
                    selectedImage: img("tabbar-icon-accounts-selected")
                )
            case .history:
                return (
                    title: "tabbar-item-history".localized,
                    normalImage: img("tabbar-icon-history"),
                    selectedImage: img("tabbar-icon-history-selected")
                )
            case .contacts:
                return (
                    title: "tabbar-item-contacts".localized,
                    normalImage: img("tabbar-icon-contacts"),
                    selectedImage: img("tabbar-icon-contacts-selected")
                )
            case .settings:
                return (
                    title: "tabbar-item-settings".localized,
                    normalImage: img("tabbar-icon-settings"),
                    selectedImage: img("tabbar-icon-settings-selected")
                )
            }
        }
    }
}

extension TabBar.Item: CaseIterable { }
