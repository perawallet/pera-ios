//
//  AccountsEmptyStateView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionsEmptyStateView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleInset: CGFloat = 79.0
        let topImageViewInset: CGFloat = 13.0
        let bottomImageViewInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.montserrat, withWeight: .medium(size: 14.0)))
            .withText("accounts-tranaction-empty-text".localized)
    }()
    
    private lazy var topImageView = UIImageView(image: img("icon-transaction-empty-green"))
    
    private lazy var bottomImageView = UIImageView(image: img("icon-transaction-empty-blue"))
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupTopImageViewLayout()
        setupBottomImageViewLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.titleInset)
        }
    }
    
    private func setupTopImageViewLayout() {
        addSubview(topImageView)
        
        topImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.topImageViewInset)
        }
    }
    
    private func setupBottomImageViewLayout() {
        addSubview(bottomImageView)
        
        bottomImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topImageView.snp.bottom).offset(layout.current.bottomImageViewInset)
        }
    }
}
