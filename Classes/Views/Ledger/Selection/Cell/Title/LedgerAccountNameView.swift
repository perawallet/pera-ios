//
//  LedgerAccountNameView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountNameView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerAccountNameViewDelegate?
    
    private lazy var selectionImageView = UIImageView()
    
    private lazy var accountNameView = AccountNameView()
    
    private lazy var infoButton: UIButton = {
        UIButton(type: .custom).withImage(img("icon-info-green"))
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Component.separator
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
        infoButton.addTarget(self, action: #selector(notifyDelegateToOpenMoreInfo), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupSelectionImageViewLayout()
        setupInfoButtonLayout()
        setupAccountNameViewLayout()
        setupSeparatorViewLayout()
    }
}

extension LedgerAccountNameView {
    private func setupSelectionImageViewLayout() {
        addSubview(selectionImageView)
        
        selectionImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.imageSize)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupInfoButtonLayout() {
        addSubview(infoButton)
        
        infoButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.trailingInset)
            make.size.equalTo(layout.current.buttonSize)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupAccountNameViewLayout() {
        addSubview(accountNameView)
        
        accountNameView.snp.makeConstraints { make in
            make.leading.equalTo(selectionImageView.snp.trailing).offset(layout.current.accountNameInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
            make.trailing.lessThanOrEqualTo(infoButton.snp.leading).offset(-layout.current.trailingInset)
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

extension LedgerAccountNameView {
    @objc
    private func notifyDelegateToOpenMoreInfo() {
        delegate?.ledgerAccountNameViewDidOpenInfo(self)
    }
}

extension LedgerAccountNameView {
    func bind(_ viewModel: LedgerAccountNameViewModel) {
        selectionImageView.image = viewModel.selectionImage
        accountNameView.bind(viewModel.accountNameViewModel)
    }
}

extension LedgerAccountNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 20.0
        let trailingInset: CGFloat = 16.0
        let accountNameInset: CGFloat = 16.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let separatorHeight: CGFloat = 1.0
    }
}

protocol LedgerAccountNameViewDelegate: class {
    func ledgerAccountNameViewDidOpenInfo(_ ledgerAccountNameView: LedgerAccountNameView)
}
