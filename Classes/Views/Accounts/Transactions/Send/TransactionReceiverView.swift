//
//  TransactionReceiverView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum AssetReceiverState: Equatable {
    case initial
    case contact(Contact)
    case myAccount(Account)
    case address(address: String, amount: String?)
}

protocol TransactionReceiverViewDelegate: class {
    func transactionReceiverViewDidTapAddressButton(_ transactionReceiverView: TransactionReceiverView)
    func transactionReceiverViewDidTapMyAccountsButton(_ transactionReceiverView: TransactionReceiverView)
    func transactionReceiverViewDidTapContactsButton(_ transactionReceiverView: TransactionReceiverView)
    func transactionReceiverViewDidTapScanQRButton(_ transactionReceiverView: TransactionReceiverView)
    func transactionReceiverViewDidTapActionButton(
        _ transactionReceiverView: TransactionReceiverView,
        with mode: TransactionReceiverView.ActionMode
    )
}

extension TransactionReceiverViewDelegate {
    func transactionReceiverViewDidTapAddressButton(_ transactionReceiverView: TransactionReceiverView) {
        
    }
    
    func transactionReceiverViewDidTapMyAccountsButton(_ transactionReceiverView: TransactionReceiverView) {
        
    }
    
    func transactionReceiverViewDidTapContactsButton(_ transactionReceiverView: TransactionReceiverView) {
        
    }
    
    func transactionReceiverViewDidTapScanQRButton(_ transactionReceiverView: TransactionReceiverView) {
        
    }
    
    func transactionReceiverViewDidTapActionButton(
        _ transactionReceiverView: TransactionReceiverView,
        with mode: TransactionReceiverView.ActionMode
    ) {
        
    }
}

class TransactionReceiverView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 30.0
        let containerTopInset: CGFloat = 7.0
        let qrButtonInset: CGFloat = 63.0
        let inputViewInset: CGFloat = 55.0
        let verticalInset: CGFloat = 15.0
        let inputViewHeight: CGFloat = 44.0
        let buttonSize: CGFloat = 38.0
        let buttonInset: CGFloat = 15.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let buttonColor = rgb(0.34, 0.34, 0.43)
        static let borderColor = rgb(0.94, 0.94, 0.94)
    }
    
    enum ActionMode: Equatable {
        case none
        case close
        case qrView
        case contactAddition
    }
    
    weak var delegate: TransactionReceiverViewDelegate?
    
    var state: AssetReceiverState = .initial {
        didSet {
            if state == oldValue {
                return
            }
            
            switch state {
            case .initial:
                actionButton.isHidden = true
                
                if passphraseInputView.superview != nil {
                    passphraseInputView.removeFromSuperview()
                }
                
                if receiverContactView.superview != nil {
                    receiverContactView.removeFromSuperview()
                }
                
                if buttonsContainerView.isHidden {
                    buttonsContainerView.isHidden = false
                }
            case let .address(address, _):
                actionButton.isHidden = false
                buttonsContainerView.isHidden = true
                
                if receiverContactView.superview != nil {
                    receiverContactView.removeFromSuperview()
                }
                
                if passphraseInputView.superview == nil {
                    setupPassphraseInputViewLayout()
                }
                
                if address.isEmpty {
                    return
                }
                
                configurePassphraseInputView(with: address)
            case let .contact(contact):
                actionButton.isHidden = false
                buttonsContainerView.isHidden = true
                
                if passphraseInputView.superview != nil {
                    passphraseInputView.removeFromSuperview()
                }
                
                if receiverContactView.superview == nil {
                    setupReceiverContactViewLayout()
                }
                
                configureReceiverContactView(with: contact)
            case let .myAccount(account):
                actionButton.isHidden = false
                buttonsContainerView.isHidden = true
                
                if receiverContactView.superview != nil {
                    receiverContactView.removeFromSuperview()
                }
                
                if passphraseInputView.superview == nil {
                    setupPassphraseInputViewLayout()
                }
                
                configurePassphraseInputView(with: account.address)
            }
        }
    }
    
    var actionMode: ActionMode = .close {
        didSet {
            if actionMode == oldValue {
                return
            }
            
            switch actionMode {
            case .none:
                actionButton.setImage(nil, for: .normal)
            case .close:
                actionButton.setImage(img("icon-close-gray"), for: .normal)
            case .qrView:
                actionButton.setImage(img("icon-qr-view"), for: .normal)
            case .contactAddition:
                actionButton.setImage(img("icon-contact-add"), for: .normal)
            }
        }
    }
    
    private func configurePassphraseInputView(with address: String) {
        if actionMode != .none {
            passphraseInputView.snp.updateConstraints { make in
                make.trailing.equalToSuperview().inset(65.0)
            }
        }
        
        passphraseInputView.value = address
    }
    
    private func configureReceiverContactView(with contact: Contact) {
        if let imageData = contact.image,
            let image = UIImage(data: imageData) {
            let resizedImage = image.convert(to: CGSize(width: 50.0, height: 50.0))
            
            receiverContactView.userImageView.image = resizedImage
        }
        
        receiverContactView.qrDisplayButton.isHidden = true
        receiverContactView.separatorView.isHidden = true
        receiverContactView.nameLabel.text = contact.name
        receiverContactView.addressLabel.text = contact.address?.shortAddressDisplay()
    }
    
    // MARK: Components
    
    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        label.text = "send-algos-to".localized
        label.textColor = SharedColors.greenishGray
        return label
    }()
    
    private(set) lazy var receiverContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4.0
        view.layer.borderColor = Colors.borderColor.cgColor
        view.layer.borderWidth = 1.0
        return view
    }()
    
    private(set) lazy var passphraseInputView: MultiLineInputField = {
        let passphraseInputView = MultiLineInputField(displaysExplanationText: false)
        passphraseInputView.placeholderLabel.text = "contacts-input-address-placeholder".localized
        passphraseInputView.nextButtonMode = .submit
        passphraseInputView.backgroundColor = .clear
        passphraseInputView.inputTextView.backgroundColor = .clear
        passphraseInputView.contentView.layer.borderWidth = 0.0
        passphraseInputView.inputTextView.autocorrectionType = .no
        passphraseInputView.inputTextView.autocapitalizationType = .none
        passphraseInputView.inputTextView.textContainer.heightTracksTextView = false
        passphraseInputView.inputTextView.isScrollEnabled = true
        return passphraseInputView
    }()
    
    private(set) lazy var receiverContactView: ContactContextView = {
        let view = ContactContextView()
        view.backgroundColor = .clear
        return view
    }()
    
    private(set) lazy var actionButton: UIButton = {
        UIButton(type: .custom).withImage(img("icon-close-gray"))
    }()
    
    private lazy var buttonsContainerView = UIView()
    
    private lazy var addressButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 0.0, y: 18.0), title: CGPoint(x: 0.0, y: -12.0))
        
        let button = AlignedButton(style: .imageTop(positions))
        button.setImage(img("icon-address"), for: .normal)
        button.setTitle("send-algos-address".localized, for: .normal)
        button.setTitleColor(Colors.buttonColor, for: .normal)
        button.titleLabel?.font = UIFont.font(.overpass, withWeight: .semiBold(size: 11.0))
        button.backgroundColor = .white
        button.layer.cornerRadius = 4.0
        button.layer.borderColor = Colors.borderColor.cgColor
        button.layer.borderWidth = 1.0
        return button
    }()
    
    private lazy var myAccountsButton: UIButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 0.0, y: 22.0), title: CGPoint(x: 0.0, y: -12.0))
        
        let button = AlignedButton(style: .imageTop(positions))
        button.setImage(img("icon-my-accounts"), for: .normal)
        button.setTitle("send-algos-my-accounts".localized, for: .normal)
        button.setTitleColor(Colors.buttonColor, for: .normal)
        button.titleLabel?.font = UIFont.font(.overpass, withWeight: .semiBold(size: 11.0))
        button.backgroundColor = .white
        button.layer.cornerRadius = 4.0
        button.layer.borderColor = Colors.borderColor.cgColor
        button.layer.borderWidth = 1.0
        return button
    }()
    
    private lazy var contactsButton: UIButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 0.0, y: 22.0), title: CGPoint(x: 0.0, y: -12.0))
        
        let button = AlignedButton(style: .imageTop(positions))
        button.setImage(img("icon-contact"), for: .normal)
        button.setTitle("send-algos-contacts".localized, for: .normal)
        button.setTitleColor(Colors.buttonColor, for: .normal)
        button.titleLabel?.font = UIFont.font(.overpass, withWeight: .semiBold(size: 11.0))
        button.backgroundColor = .white
        button.layer.cornerRadius = 4.0
        button.layer.borderColor = Colors.borderColor.cgColor
        button.layer.borderWidth = 1.0
        return button
    }()
    
    private lazy var scanQRButton: UIButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 0.0, y: 20.0), title: CGPoint(x: 0.0, y: -12.0))
        
        let button = AlignedButton(style: .imageTop(positions))
        button.setImage(img("icon-qr-scan-send"), for: .normal)
        button.setTitle("send-algos-scan".localized, for: .normal)
        button.setTitleColor(Colors.buttonColor, for: .normal)
        button.titleLabel?.font = UIFont.font(.overpass, withWeight: .semiBold(size: 11.0))
        button.backgroundColor = .white
        button.layer.cornerRadius = 4.0
        button.layer.borderColor = Colors.borderColor.cgColor
        button.layer.borderWidth = 1.0
        return button
    }()
    
    // MARK: Setup
    
    override func setListeners() {
        addressButton.addTarget(self, action: #selector(notifyDelegateToAddressButtonTapped), for: .touchUpInside)
        myAccountsButton.addTarget(self, action: #selector(notifyDelegateToMyAccountsButtonTapped), for: .touchUpInside)
        contactsButton.addTarget(self, action: #selector(notifyDelegateToContactsButtonTapped), for: .touchUpInside)
        scanQRButton.addTarget(self, action: #selector(notifyDelegateToScanQRButtonTapped), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(notifyDelegateToActionButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupReceiverContainerViewLayout()
        setupActionButtonLayout()
        setupButtonsContainerViewLayout()
        setupAddressButtonLayout()
        setupMyAccountsButtonLayout()
        setupContactsButtonLayout()
        setupScanQRButtonLayout()
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
            make.leading.trailing.equalToSuperview().inset(15.0)
        }
    }
    
    private func setupPassphraseInputViewLayout() {
        receiverContainerView.addSubview(passphraseInputView)
        
        passphraseInputView.contentView.snp.updateConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        
        passphraseInputView.inputTextView.snp.makeConstraints { make in
            make.height.equalTo(layout.current.inputViewHeight)
        }
        
        passphraseInputView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.inputViewInset)
        }
    }
    
    private func setupReceiverContactViewLayout() {
        receiverContainerView.addSubview(receiverContactView)
        
        receiverContactView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(actionButton.snp.leading).offset(-5.0)
        }
        
        receiverContactView.userImageView.snp.updateConstraints { make in
            make.top.bottom.leading.equalToSuperview().inset(15.0)
        }
        
        receiverContactView.nameLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
        }
        
        receiverContactView.qrDisplayButton.removeFromSuperview()
    }
    
    private func setupActionButtonLayout() {
        receiverContainerView.addSubview(actionButton)
        
        actionButton.isHidden = true
        
        actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.0).priority(.required)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 40.0, height: 40.0)).priority(.required)
        }
    }
    
    private func setupButtonsContainerViewLayout() {
        addSubview(buttonsContainerView)
        
        buttonsContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(7.0)
            make.leading.trailing.equalToSuperview().inset(15.0)
            make.height.equalTo(75.0)
        }
    }
    
    private func setupAddressButtonLayout() {
        buttonsContainerView.addSubview(addressButton)
        
        addressButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo((UIScreen.main.bounds.width - 75.0) / 4)
        }
    }
    
    private func setupMyAccountsButtonLayout() {
        buttonsContainerView.addSubview(myAccountsButton)
        
        myAccountsButton.snp.makeConstraints { make in
            make.width.height.equalTo(addressButton)
            make.leading.equalTo(addressButton.snp.trailing).offset(15.0)
            make.top.bottom.equalTo(addressButton)
        }
    }
    
    private func setupContactsButtonLayout() {
        buttonsContainerView.addSubview(contactsButton)
        
        contactsButton.snp.makeConstraints { make in
            make.width.height.equalTo(addressButton)
            make.leading.equalTo(myAccountsButton.snp.trailing).offset(15.0)
            make.top.bottom.equalTo(addressButton)
        }
    }
    
    private func setupScanQRButtonLayout() {
        buttonsContainerView.addSubview(scanQRButton)
        
        scanQRButton.snp.makeConstraints { make in
            make.width.height.equalTo(addressButton)
            make.leading.equalTo(contactsButton.snp.trailing).offset(15.0)
            make.top.bottom.equalTo(addressButton)
            make.trailing.equalToSuperview()
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToAddressButtonTapped() {
        state = .address(address: "", amount: nil)
        delegate?.transactionReceiverViewDidTapAddressButton(self)
    }
    
    @objc
    private func notifyDelegateToMyAccountsButtonTapped() {
        delegate?.transactionReceiverViewDidTapMyAccountsButton(self)
    }
    
    @objc
    private func notifyDelegateToContactsButtonTapped() {
        delegate?.transactionReceiverViewDidTapContactsButton(self)
    }
    @objc
    private func notifyDelegateToScanQRButtonTapped() {
        delegate?.transactionReceiverViewDidTapScanQRButton(self)
    }
    
    @objc
    private func notifyDelegateToActionButtonTapped() {
        switch actionMode {
        case .close:
            state = .initial
        default:
            delegate?.transactionReceiverViewDidTapActionButton(self, with: actionMode)
        }
    }
}
