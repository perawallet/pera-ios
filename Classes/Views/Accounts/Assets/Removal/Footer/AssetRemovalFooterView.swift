//
//  AssetRemovalFooterView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AssetRemovalFooterView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var containerView = UIView()
    
    override func configureAppearance() {
        super.configureAppearance()
        containerView.backgroundColor = SharedColors.secondaryBackground
        containerView.layer.cornerRadius = 12.0
        containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
    }
}

extension AssetRemovalFooterView {
    private func setupContainerViewLayout() {
        addSubview(containerView)
    
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.containerHeight)
        }
    }
}

extension AssetRemovalFooterView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let containerHeight: CGFloat = 8.0
    }
}
