//
//  TransactionReceiverView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionReceiverView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: TransactionReceiverViewDelegate?
    
    var addressText: String {
        return addressInputView.inputTextView.text
    }
    
    var state: AssetReceiverState = .initial {
        didSet {
            if state == oldValue {
                return
            }
            
            switch state {
            case .initial:
                if addressInputView.superview != nil {
                    addressInputView.removeFromSuperview()
                }
                
                if receiverContactView.superview != nil {
                    receiverContactView.removeFromSuperview()
                }
                
                if transactionReceiverSelectionView.isHidden {
                    transactionReceiverSelectionView.isHidden = false
                }
            case let .address(address, _):
                transactionReceiverSelectionView.isHidden = true
                
                if receiverContactView.superview != nil {
                    receiverContactView.removeFromSuperview()
                }
                
                if addressInputView.superview == nil {
                    setupPassphraseInputViewLayout()
                }
                
                if address.isEmpty {
                    return
                }
                
                addressInputView.value = address
            case let .contact(contact):
                transactionReceiverSelectionView.isHidden = true
                
                if addressInputView.superview != nil {
                    addressInputView.removeFromSuperview()
                }
                
                if receiverContactView.superview == nil {
                    setupReceiverContactViewLayout()
                }
                
                configureReceiverContactView(with: contact)
            case let .myAccount(account):
                transactionReceiverSelectionView.isHidden = true
                
                if receiverContactView.superview != nil {
                    receiverContactView.removeFromSuperview()
                }
                
                if addressInputView.superview == nil {
                    setupPassphraseInputViewLayout()
                }
                
                addressInputView.value = account.address
            }
        }
    }
    
    private lazy var toLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withText("send-algos-to".localized)
    }()
    
    private(set) lazy var receiverContainerView = UIView()
    
    private lazy var transactionReceiverSelectionView = TransactionReceiverSelectionView()
    
    private lazy var addressInputView: MultiLineInputField = {
        let addressInputView = MultiLineInputField(displaysExplanationText: false, displaysRightInputAccessoryButton: true)
        addressInputView.placeholderLabel.text = "contacts-input-address-placeholder".localized
        addressInputView.nextButtonMode = .submit
        addressInputView.inputTextView.autocorrectionType = .no
        addressInputView.inputTextView.autocapitalizationType = .none
        addressInputView.inputTextView.textContainer.heightTracksTextView = true
        addressInputView.inputTextView.isScrollEnabled = false
        addressInputView.rightInputAccessoryButton.setImage(img("img-remove-sender"), for: .normal)
        return addressInputView
    }()
    
    private(set) lazy var receiverContactView: ContactContextView = {
        let view = ContactContextView()
        view.backgroundColor = Colors.Background.secondary
        view.layer.cornerRadius = 12.0
        view.qrDisplayButton.setImage(img("img-remove-sender"), for: .normal)
        return view
    }()
    
    override func linkInteractors() {
        transactionReceiverSelectionView.delegate = self
        receiverContactView.delegate = self
        addressInputView.delegate = self
    }
    
    override func prepareLayout() {
        setupToLabelLayout()
        setupReceiverContainerViewLayout()
        setupTransactionReceiverSelectionViewLayout()
    }
}

extension TransactionReceiverView {
    private func setupToLabelLayout() {
        addSubview(toLabel)
        
        toLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.titleHorizontalInset)
        }
    }
    
    private func setupReceiverContainerViewLayout() {
        addSubview(receiverContainerView)
        
        receiverContainerView.snp.makeConstraints { make in
            make.top.equalTo(toLabel.snp.bottom).offset(layout.current.containerTopInset)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    private func setupTransactionReceiverSelectionViewLayout() {
        addSubview(transactionReceiverSelectionView)
        
        transactionReceiverSelectionView.snp.makeConstraints { make in
            make.top.equalTo(toLabel.snp.bottom).offset(layout.current.containerTopInset)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}

extension TransactionReceiverView {
    private func setupPassphraseInputViewLayout() {
        receiverContainerView.addSubview(addressInputView)
        
        addressInputView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    private func setupReceiverContactViewLayout() {
        receiverContainerView.addSubview(receiverContactView)
        
        receiverContactView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.contactHorizontalInset)
            make.top.bottom.equalToSuperview()
        }
    }
    
    private func configureReceiverContactView(with contact: Contact) {
        if let imageData = contact.image,
            let image = UIImage(data: imageData) {
            let resizedImage = image.convert(to: CGSize(width: 44.0, height: 44.0))
            receiverContactView.userImageView.image = resizedImage
        }
        
        receiverContactView.nameLabel.text = contact.name
        receiverContactView.addressLabel.text = contact.address?.shortAddressDisplay()
    }
}

extension TransactionReceiverView: TransactionReceiverSelectionViewDelegate {
    func transactionReceiverSelectionViewDidTapAccountsButton(_ transactionReceiverSelectionView: TransactionReceiverSelectionView) {
        delegate?.transactionReceiverViewDidTapAccountsButton(self)
    }
    
    func transactionReceiverSelectionViewDidTapContactsButton(_ transactionReceiverSelectionView: TransactionReceiverSelectionView) {
        delegate?.transactionReceiverViewDidTapContactsButton(self)
    }
    
    func transactionReceiverSelectionViewDidTapAddressButton(_ transactionReceiverSelectionView: TransactionReceiverSelectionView) {
        delegate?.transactionReceiverViewDidTapAddressButton(self)
    }
    
    func transactionReceiverSelectionViewDidTapQRButton(_ transactionReceiverSelectionView: TransactionReceiverSelectionView) {
        delegate?.transactionReceiverViewDidTapScanQRButton(self)
    }
}

extension TransactionReceiverView: ContactContextViewDelegate {
    func contactContextViewDidTapQRDisplayButton(_ contactContextView: ContactContextView) {
        delegate?.transactionReceiverViewDidTapCloseButton(self)
    }
}

extension TransactionReceiverView: InputViewDelegate {
    func inputViewDidTapAccessoryButton(inputView: BaseInputView) {
        delegate?.transactionReceiverViewDidTapCloseButton(self)
    }
}

extension TransactionReceiverView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleHorizontalInset: CGFloat = 24.0
        let containerTopInset: CGFloat = 8.0
        let contactHorizontalInset: CGFloat = 20.0
    }
}

enum AssetReceiverState: Equatable {
    case initial
    case contact(Contact)
    case myAccount(Account)
    case address(address: String, amount: String?)
}

protocol TransactionReceiverViewDelegate: class {
    func transactionReceiverViewDidTapCloseButton(_ transactionReceiverView: TransactionReceiverView)
    func transactionReceiverViewDidTapAccountsButton(_ transactionReceiverView: TransactionReceiverView)
    func transactionReceiverViewDidTapContactsButton(_ transactionReceiverView: TransactionReceiverView)
    func transactionReceiverViewDidTapAddressButton(_ transactionReceiverView: TransactionReceiverView)
    func transactionReceiverViewDidTapScanQRButton(_ transactionReceiverView: TransactionReceiverView)
}
