//
//  TransactionReceiverView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum AlgosReceiverState: Equatable {
    case initial
    case contact(Contact)
    case address(String)
}

protocol TransactionReceiverViewDelegate: class {
    
    func transactionReceiverViewDidTapContactsButton(_ transactionReceiverView: TransactionReceiverView)
    func transactionReceiverViewDidTapQRButton(_ transactionReceiverView: TransactionReceiverView)
}

class TransactionReceiverView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 25.0
        let separatorHeight: CGFloat = 1.0
        let containerTopInset: CGFloat = 7.0
        let qrButtonInset: CGFloat = 65.0
        let inputViewInset: CGFloat = 85.0
        let verticalInset: CGFloat = 20.0
        let inputViewHeight: CGFloat = 40.0
        let buttonSize: CGFloat = 20.0
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
            
            switch state {
            case .initial:
                passphraseInputView.isHidden = false
                
                if receiverContactView.superview != nil {
                    receiverContactView.removeFromSuperview()
                }
                
            case let .address(address):
                if passphraseInputView.isHidden {
                    passphraseInputView.isHidden = false
                    receiverContactView.removeFromSuperview()
                }
                
                configurePassphraseInputView(with: address)
            case let .contact(contact):
                if receiverContactView.superview == nil {
                    setupReceiverContactViewLayout()
                }
                
                configureReceiverContactView(with: contact)
            }
        }
    }
    
    private func configurePassphraseInputView(with address: String) {
        contactsButton.isHidden = true
        
        let width = UIScreen.main.bounds.width - 105.0
        let font = UIFont.font(.montserrat, withWeight: .semiBold(size: 13.0))
        
        let height = address.height(withConstrained: width, font: font) + 6
        
        passphraseInputView.inputTextView.snp.updateConstraints { make in
            make.height.equalTo(height)
            make.top.equalToSuperview().inset(-5.0)
        }
        
        qrButton.snp.updateConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
        
        passphraseInputView.value = address
    }
    
    private func configureReceiverContactView(with contact: Contact) {
        if let imageData = contact.image,
            let image = UIImage(data: imageData) {
            let resizedImage = image.convert(to: CGSize(width: 50.0, height: 50.0))
            
            receiverContactView.userImageView.image = resizedImage
        }
        
        receiverContactView.userImageView.backgroundColor = .white
        receiverContactView.qrDisplayButton.setImage(img("icon-contacts"), for: .normal)
        receiverContactView.separatorView.isHidden = true
        receiverContactView.nameLabel.text = contact.name
        receiverContactView.addressLabel.text = contact.address
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
        passphraseInputView.inputTextView.textContainer.heightTracksTextView = false
        passphraseInputView.inputTextView.isScrollEnabled = true
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
    
    private(set) lazy var receiverContactView: ContactContextView = {
        let view = ContactContextView()
        view.backgroundColor = SharedColors.warmWhite
        return view
    }()
    
    private(set) lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    // MARK: Setup
    
    override func setListeners() {
        qrButton.addTarget(self, action: #selector(notifyDelegateToQRButtonTapped), for: .touchUpInside)
        contactsButton.addTarget(self, action: #selector(notifyDelegateToContactsButtonTapped), for: .touchUpInside)
        
        receiverContactView.qrDisplayButton.addTarget(self, action: #selector(notifyDelegateToContactsButtonTapped), for: .touchUpInside)
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
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupReceiverContainerViewLayout() {
        addSubview(receiverContainerView)
        
        receiverContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.containerTopInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupPassphraseInputViewLayout() {
        receiverContainerView.addSubview(passphraseInputView)
        
        passphraseInputView.contentView.snp.updateConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        passphraseInputView.inputTextView.snp.makeConstraints { make in
            make.height.equalTo(layout.current.inputViewHeight)
        }
        
        passphraseInputView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.inputViewInset)
            make.height.equalTo(layout.current.inputViewHeight).priority(.low)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupQRButtonLayout() {
        receiverContainerView.addSubview(qrButton)
        
        qrButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.qrButtonInset)
            make.top.equalTo(passphraseInputView.snp.top)
            make.width.height.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupContactsButtonLayout() {
        receiverContainerView.addSubview(contactsButton)
        
        contactsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(passphraseInputView.snp.top)
            make.width.height.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupReceiverContactViewLayout() {
        passphraseInputView.isHidden = true
        
        receiverContainerView.addSubview(receiverContactView)
        
        receiverContactView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        receiverContactView.userImageView.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(0.0)
        }
        
        receiverContactView.qrDisplayButton.snp.updateConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
        
        separatorView.snp.updateConstraints { make in
            make.top.equalTo(receiverContainerView.snp.bottom).offset(0.0)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(receiverContainerView.snp.bottom).offset(layout.current.verticalInset)
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
