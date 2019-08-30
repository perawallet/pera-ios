//
//  RewardsSwitchView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RewardsSwitchView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 15.0
        let leadingInset: CGFloat = 22.0
        let trailingInset: CGFloat = 9.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let borderColor = rgb(0.94, 0.94, 0.94)
    }
    
    // MARK: Components

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
            .withTextColor(.black)
            .withLine(.single)
            .withAlignment(.left)
            .withText("rewards-title".localized)
    }()
    
    private(set) lazy var toggle: Toggle = {
        Toggle()
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
        layer.cornerRadius = 4.0
        layer.borderColor = Colors.borderColor.cgColor
        layer.borderWidth = 1.0
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupTitleLabelLayout()
        setupToggleLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.leadingInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupToggleLayout() {
        addSubview(toggle)
        
        toggle.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.trailingInset)
            make.centerY.equalTo(titleLabel)
        }
    }
}
