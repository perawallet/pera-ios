//
//  AddNewAccountView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.04.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AddNewAccountView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AddNewAccountViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withFont(UIFont.font(withWeight: .bold(size: 28.0 * verticalScale)))
            .withText("introduction-add-new-text".localized)
            .withTextColor(SharedColors.primaryText)
            .withAlignment(.left)
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withAttributedText("introduction-add-new-title-text".localized.attributed([
                .lineSpacing(1.2),
                .textColor(SharedColors.secondaryText)
            ]))
            .withFont(UIFont.font(withWeight: .regular(size: 14.0 * verticalScale)))
    }()
    
    private lazy var createAccountButton = MainButton(title: "introduction-create-title".localized)
    
    private lazy var pairLedgerAccountButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-orange-button"))
            .withTitle("introduction-title-pair-ledger".localized)
            .withTitleColor(SharedColors.primaryButtonTitle)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.gray300
        return view
    }()
    
    private lazy var hasAccountLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(SharedColors.gray500)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0 * verticalScale)))
            .withText("introduction-has-account".localized)
    }()
    
    private lazy var recoverButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withTitle("introduction-recover-title".localized)
            .withTitleColor(SharedColors.secondaryButtonTitle)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()
    
    override func setListeners() {
        createAccountButton.addTarget(self, action: #selector(notifyDelegateToCreateAccount), for: .touchUpInside)
        pairLedgerAccountButton.addTarget(self, action: #selector(notifyDelegateToPairLedgerAccount), for: .touchUpInside)
        recoverButton.addTarget(self, action: #selector(notifyDelegateToRecoverAccount), for: .touchUpInside)
    }
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
        setupCreateAccountButtonLayout()
        setupPairLedgerAccountButtonLayout()
        setupSeparatorViewLayout()
        setupHasAccountLabelLayout()
        setupRecoverButtonLayout()
    }
}

extension AddNewAccountView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.titleLabelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleLabelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupCreateAccountButtonLayout() {
        addSubview(createAccountButton)
        
        createAccountButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.createButtonTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupPairLedgerAccountButtonLayout() {
        addSubview(pairLedgerAccountButton)
        
        pairLedgerAccountButton.snp.makeConstraints { make in
            make.top.equalTo(createAccountButton.snp.bottom).offset(layout.current.pairButtonTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(pairLedgerAccountButton.snp.bottom).offset(layout.current.separatorVerticalInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupHasAccountLabelLayout() {
        addSubview(hasAccountLabel)
        
        hasAccountLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(layout.current.separatorVerticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupRecoverButtonLayout() {
        addSubview(recoverButton)
        
        recoverButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.recoverButtonTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
        }
    }
}

extension AddNewAccountView {
    @objc
    func notifyDelegateToCreateAccount() {
        delegate?.addNewAccountViewDidTapCreateAccountButton(self)
    }
    
    @objc
    func notifyDelegateToPairLedgerAccount() {
        delegate?.addNewAccountViewDidTapPairLedgerAccountButton(self)
    }

    @objc
    func notifyDelegateToRecoverAccount() {
        delegate?.addNewAccountViewDidTapRecoverButton(self)
    }
}

extension AddNewAccountView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageViewHeight: CGFloat = 192.0 * verticalScale
        let imageViewLeadingInset: CGFloat = 28.0
        let imageViewTopInset: CGFloat = 50.0 * verticalScale
        let titleLabelTopInset: CGFloat = 150.0 * verticalScale
        let subtitleLabelTopInset: CGFloat = 12.0 * verticalScale
        let separatorHeight: CGFloat = 1.0
        let separatorVerticalInset: CGFloat = 32.0 * verticalScale
        let createButtonTopInset: CGFloat = 40.0 * verticalScale
        let pairButtonTopInset: CGFloat = 20.0 * verticalScale
        let bottomInset: CGFloat = 20.0 * verticalScale
        let recoverButtonTopInset: CGFloat = 16.0 * verticalScale
        let horizontalInset: CGFloat = 32.0
    }
}

protocol AddNewAccountViewDelegate: class {
    func addNewAccountViewDidTapCreateAccountButton(_ addNewAccountView: AddNewAccountView)
    func addNewAccountViewDidTapPairLedgerAccountButton(_ addNewAccountView: AddNewAccountView)
    func addNewAccountViewDidTapRecoverButton(_ addNewAccountView: AddNewAccountView)
}
