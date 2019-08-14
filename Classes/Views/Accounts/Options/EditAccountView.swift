//
//  EditAccountView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol EditAccountViewDelegate: class {
    
    func editAccountViewDidTapSaveButton(_ editAccountView: EditAccountView)
}

class EditAccountView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 25.0
        let verticalInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let separatorInset: CGFloat = 16.0
        let fieldHeight: CGFloat = 50.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let backgroundColor = rgb(0.97, 0.97, 0.97)
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    // MARK: Components
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.darkGray)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
            .withText("options-edit-account-name".localized)
    }()
    
    private lazy var saveButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.turquois)
            .withTitle("title-save".localized)
            .withAlignment(.right)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var accountNameInputView: SingleLineInputField = {
        let accountNameInputView = SingleLineInputField()
        accountNameInputView.explanationLabel.text = "account-name-setup-explanation".localized
        accountNameInputView.inputTextField.attributedPlaceholder = NSAttributedString(
            string: "account-name-setup-placeholder".localized,
            attributes: [NSAttributedString.Key.foregroundColor: SharedColors.softGray,
                         NSAttributedString.Key.font: UIFont.font(.overpass, withWeight: .semiBold(size: 15.0))]
        )
        accountNameInputView.nextButtonMode = .submit
        accountNameInputView.inputTextField.autocorrectionType = .no
        accountNameInputView.backgroundColor = .clear
        return accountNameInputView
    }()
    
    weak var delegate: EditAccountViewDelegate?
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = backgroundColor
    }
    
    override func setListeners() {
        saveButton.addTarget(self, action: #selector(notifyDelegateToSaveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupSaveButtonLayout()
        setupSeparatorViewLayout()
        setupAccountNameInputViewLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupSaveButtonLayout() {
        addSubview(saveButton)
        
        saveButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.separatorInset)
        }
    }
    
    private func setupAccountNameInputViewLayout() {
        addSubview(accountNameInputView)
        
        accountNameInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(separatorView.snp.bottom).offset(layout.current.verticalInset)
            make.height.equalTo(layout.current.fieldHeight)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToSaveButtonTapped() {
        delegate?.editAccountViewDidTapSaveButton(self)
    }
}
