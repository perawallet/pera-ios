//
//  AccountNameView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AccountNameView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let lineHeight: CGFloat = 2.0
        let topInset: CGFloat = 25.0
        let lineTopInset: CGFloat = 5.0
    }
    
    private let layout = Layout<LayoutConstants>()

    // MARK: Components
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .bold(size: 11.0)))
            .withTextColor(SharedColors.darkGray)
            .withLine(.single)
    }()
    
    private(set) lazy var bottomLineView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.layer.cornerRadius = 1.0
        view.backgroundColor = SharedColors.purple
        return view
    }()
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupBottomLineViewLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.lessThanOrEqualToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupBottomLineViewLayout() {
        addSubview(bottomLineView)
        
        bottomLineView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.lineTopInset)
            make.height.equalTo(layout.current.lineHeight)
        }
    }
    
    // MARK: API
    
    func set(selected: Bool) {
        if selected {
            titleLabel.textColor = SharedColors.purple
            bottomLineView.isHidden = false
        } else {
            titleLabel.textColor = SharedColors.darkGray
            bottomLineView.isHidden = true
        }
    }
}
