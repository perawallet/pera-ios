//
//  TabBar.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TabBar: BaseView {
    
    var barButtonItems: [TabBarButtonItemConvertible] = [] {
        didSet {
            updateLayoutWhenBarButtonItemsChanged()
        }
    }
    
    var selectedBarButtonIndex: Int? {
        didSet {
            updateLayoutWhenSelectedBarButtonItemChanged()
        }
    }
   
    var barButtonDidSelect: ((Int) -> Void)?
    
    var centerButtonDidTap: ((Int) -> Void)?

    private lazy var container = UIStackView()

    var barButtons: [TabBarButton] {
        return container.arrangedSubviews as? [TabBarButton] ?? []
    }

    private var selectedBarButton: TabBarButton?

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 62.0 + compactSafeAreaInsets.bottom)
    }
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        addContainer()
    }
}

extension TabBar {
    private func addContainer() {
        addSubview(container)
        container.axis = .horizontal
        container.alignment = .fill
        container.distribution = .fill
        container.spacing = 0.0
        container.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.leading.equalToSuperview()
            maker.bottom.equalTo(safeAreaLayoutGuide)
            maker.trailing.equalToSuperview()
        }
    }

    private func addBarButtons() {
        var referenceAutosizedBarButton: TabBarButton?

        barButtonItems.forEach { barButtonItem in
            let barButton = TabBarButton(barButtonItem)

            container.addArrangedSubview(barButton)
            barButton.snp.makeConstraints { maker in
                if barButtonItem.width.isIntrinsicMetric {
                    maker.width.equalTo(barButtonItem.width)
                } else if let reference = referenceAutosizedBarButton {
                    maker.width.equalTo(reference)
                } else {
                    referenceAutosizedBarButton = barButton
                }
            }

            if barButtonItem.isSelectable {
                barButton.addTarget(self, action: #selector(notifyWhenBarButtonSelected(_:)), for: .touchUpInside)
            } else {
                barButton.addTarget(self, action: #selector(notifyWhenCenterBarButtonTapped), for: .touchUpInside)
            }
        }
    }

    private func removeBarButtons() {
        container.deleteAllArrangedSubviews()
    }
}

extension TabBar {
    @objc
    private func notifyWhenBarButtonSelected(_ sender: TabBarButton) {
        if let index = barButtons.firstIndex(of: sender) {
            barButtonDidSelect?(index)
        }
    }
    
    @objc
    private func notifyWhenCenterBarButtonTapped(_ sender: TabBarButton) {
        if let index = barButtons.firstIndex(of: sender) {
            centerButtonDidTap?(index)
        }
    }
}

extension TabBar {
    func getBadge(forBarButtonAt index: Int) -> String? {
        return barButtons[safe: index]?.badge
    }

    func set(badge: String?, forBarButtonAt index: Int, animated: Bool) {
        barButtons[safe: index]?.set(badge: badge, animated: animated)
    }
}

extension TabBar {
    func updateLayoutWhenBarButtonItemsChanged() {
        removeBarButtons()
        addBarButtons()
    }

    func updateLayoutWhenSelectedBarButtonItemChanged() {
        selectedBarButton?.isSelected = false
        selectedBarButton = barButtons[safe: selectedBarButtonIndex]
        selectedBarButton?.isSelected = true
    }
}
