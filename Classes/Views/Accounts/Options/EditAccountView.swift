//
//  EditAccountView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class EditAccountView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: EditAccountViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(SharedColors.primaryText)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withText("options-edit-account-name".localized)
    }()
    
    private lazy var doneButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.tertiaryText)
            .withTitle("title-done".localized)
            .withAlignment(.right)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()
    
    private lazy var nameTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.primaryText)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withText("account-name-setup-explanation".localized)
    }()
    
    private(set) lazy var accountNameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = SharedColors.primaryText
        textField.tintColor = SharedColors.primaryText
        textField.font = UIFont.font(withWeight: .medium(size: 18.0))
        return textField
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.primary
        return view
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func setListeners() {
        doneButton.addTarget(self, action: #selector(notifyDelegateToSaveButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupSaveButtonLayout()
        setupNameTitleLabelLayout()
        setupAccountNameInputViewLayout()
        setupSeparatorViewLayout()
    }
}

extension EditAccountView {
    @objc
    private func notifyDelegateToSaveButtonTapped() {
        delegate?.editAccountViewDidTapSaveButton(self)
    }
}

extension EditAccountView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupSaveButtonLayout() {
        addSubview(doneButton)
        
        doneButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.topInset)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    private func setupNameTitleLabelLayout() {
        addSubview(nameTitleLabel)
        
        nameTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.nameTitleTopInset)
        }
    }
    
    private func setupAccountNameInputViewLayout() {
        addSubview(accountNameTextField)
        
        accountNameTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(nameTitleLabel.snp.bottom).offset(layout.current.fieldTopInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(accountNameTextField.snp.bottom).offset(layout.current.separatorInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension EditAccountView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let topInset: CGFloat = 16.0
        let nameTitleTopInset: CGFloat = 32.0
        let fieldTopInset: CGFloat = 7.0
        let separatorHeight: CGFloat = 2.0
        let separatorInset: CGFloat = 3.0
        let bottomInset: CGFloat = 24.0
    }
}

protocol EditAccountViewDelegate: class {
    func editAccountViewDidTapSaveButton(_ editAccountView: EditAccountView)
}
