//
//  LedgerInfoAccountNameView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 16.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerInfoAccountNameView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var accountNameView = AccountNameView()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupAccountNameViewLayout()
        setupSeparatorViewLayout()
    }
}

extension LedgerInfoAccountNameView {
    private func setupAccountNameViewLayout() {
        addSubview(accountNameView)
        
        accountNameView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
        
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
            
        separatorView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.leading.equalTo(accountNameView)
            make.height.equalTo(layout.current.separatorHeight)
            make.bottom.equalToSuperview()
        }
    }
}

extension LedgerInfoAccountNameView {
    func bind(_ viewModel: AccountNameViewModel) {
        accountNameView.bind(viewModel)
    }
}

extension LedgerInfoAccountNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 16.0
        let verticalInset: CGFloat = 20.0
        let trailingInset: CGFloat = 8.0
        let accountNameInset: CGFloat = 24.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let separatorHeight: CGFloat = 1.0
    }
}
