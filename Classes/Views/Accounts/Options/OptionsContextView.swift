//
//  OptionsContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class OptionsContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 26.0
        let separatorHorizontalInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let labelLefInset: CGFloat = 53.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var iconImageView = UIImageView()
    
    private(set) lazy var optionLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0)))
            .withTextColor(SharedColors.black)
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.warmWhite
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupIconImageViewLayout()
        setupOptionLabelLayout()
        setupSeparatorViewLayout()
    }
    
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
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorHorizontalInset)
        }
    }
}
