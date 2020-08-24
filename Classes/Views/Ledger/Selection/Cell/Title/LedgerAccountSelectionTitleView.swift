//
//  LedgerAccountSelectionTitleView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountSelectionTitleView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var selectionImageView = UIImageView()
    
    private lazy var accountNameView = AccountNameView()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.primaryBackground
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupSelectionImageViewLayout()
        setupAccountNameViewLayout()
        setupSeparatorViewLayout()
    }
}

extension LedgerAccountSelectionTitleView {
    private func setupSelectionImageViewLayout() {
        addSubview(selectionImageView)
        
        selectionImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.imageSize)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupAccountNameViewLayout() {
        addSubview(accountNameView)
        
        accountNameView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset).priority(.medium)
            make.leading.equalTo(selectionImageView.snp.trailing).offset(layout.current.accountNameInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
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

extension LedgerAccountSelectionTitleView {
    func setSelectionImage(_ image: UIImage?) {
        selectionImageView.image = image
    }
    
    func setAccountImage(_ image: UIImage?) {
        accountNameView.setAccountImage(image)
    }
    
    func setAccountName(_ name: String?) {
        accountNameView.setAccountName(name)
    }
    
    func setEnabled(_ isEnabled: Bool) {
        if isEnabled {
            backgroundColor = SharedColors.secondaryBackground
            separatorView.backgroundColor = SharedColors.primaryBackground
        } else {
            selectionImageView.removeFromSuperview()
            backgroundColor = SharedColors.disabledBackground
            separatorView.backgroundColor = SharedColors.gray200
        }
    }
}

extension LedgerAccountSelectionTitleView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 20.0
        let accountNameInset: CGFloat = 24.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let separatorHeight: CGFloat = 1.0
    }
}
