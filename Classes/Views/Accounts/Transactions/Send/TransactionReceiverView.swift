//
//  TransactionReceiverView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum AlgosReceiverState {
    case initial
    case contact
    case address
}

protocol TransactionReceiverViewDelegate: class {
    
    func transactionReceiverViewDidTapContactsButton(_ transactionReceiverView: TransactionReceiverView)
    func transactionReceiverViewDidTapQRButton(_ transactionReceiverView: TransactionReceiverView)
}

class TransactionReceiverView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let bottomInset: CGFloat = 20.0
        let buttonMinimumInset: CGFloat = 18.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    weak var delegate: TransactionReceiverViewDelegate?
    
    var state: AlgosReceiverState = .initial {
        didSet {
            if state == oldValue {
                return
            }
            
            if state == .contact {
                
            } else {
                
            }
        }
    }
    
    // MARK: Components
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.opensans, withWeight: .semiBold(size: 12.0))
        label.text = "send-algos-to".localized
        label.textColor = SharedColors.softGray
        return label
    }()
    
    private lazy var receiverContainerView = UIView()
    
    private(set) lazy var passphraseInputView: MultiLineInputField = {
        let passphraseInputView = MultiLineInputField(displaysExplanationText: false, separatorStyle: .none)
        passphraseInputView.placeholderLabel.text = "contacts-input-address-placeholder".localized
        passphraseInputView.nextButtonMode = .submit
        passphraseInputView.inputTextView.autocorrectionType = .no
        passphraseInputView.inputTextView.autocapitalizationType = .none
        return passphraseInputView
    }()
    
    private(set) lazy var qrButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(img("icon-qr"), for: .normal)
        return button
    }()
    
    private(set) lazy var contactsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(img("icon-contacts"), for: .normal)
        return button
    }()
    
    private(set) lazy var receiverContactView = ContactContextView()
    
    private(set) lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    // MARK: Setup
    
    override func setListeners() {
        qrButton.addTarget(self, action: #selector(notifyDelegateToQRButtonTapped), for: .touchUpInside)
        contactsButton.addTarget(self, action: #selector(notifyDelegateToContactsButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupReceiverContainerViewLayout()
        setupPassphraseInputViewLayout()
        setupQRButtonLayout()
        setupContactsButtonLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20.0)
            make.leading.equalToSuperview().inset(25.0)
        }
    }
    
    private func setupReceiverContainerViewLayout() {
        addSubview(receiverContainerView)
        
        receiverContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(7.0)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupPassphraseInputViewLayout() {
        receiverContainerView.addSubview(passphraseInputView)
        
        passphraseInputView.contentView.snp.updateConstraints { make in
            make.top.equalToSuperview()
        }
        
        passphraseInputView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(85.0)
            make.height.greaterThanOrEqualTo(40.0)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupQRButtonLayout() {
        receiverContainerView.addSubview(qrButton)
        
        qrButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(65.0)
            make.top.equalTo(passphraseInputView.snp.top)
            make.width.height.equalTo(20.0)
        }
    }
    
    private func setupContactsButtonLayout() {
        receiverContainerView.addSubview(contactsButton)
        
        contactsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(25.0)
            make.top.equalTo(passphraseInputView.snp.top)
            make.width.height.equalTo(20.0)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(receiverContainerView.snp.bottom).offset(layout.current.bottomInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToQRButtonTapped() {
        delegate?.transactionReceiverViewDidTapQRButton(self)
    }
    
    @objc
    private func notifyDelegateToContactsButtonTapped() {
        delegate?.transactionReceiverViewDidTapContactsButton(self)
    }
}
