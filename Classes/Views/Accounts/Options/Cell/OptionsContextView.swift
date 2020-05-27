//
//  OptionsContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class OptionsContextView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var iconImageView = UIImageView()
    
    private(set) lazy var optionLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.primaryText)
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupIconImageViewLayout()
        setupOptionLabelLayout()
    }
}

extension OptionsContextView {
    private func setupIconImageViewLayout() {
        addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupOptionLabelLayout() {
        addSubview(optionLabel)
        
        optionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.labelLefInset)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension OptionsContextView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let labelLefInset: CGFloat = 56.0
    }
}
