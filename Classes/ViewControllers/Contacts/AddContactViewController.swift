//
//  AddContactViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AddContactViewControllerDelegate: class {
    
    func addContactViewController(_ addContactViewController: AddContactViewController, didSave contact: Contact)
}

class AddContactViewController: BaseScrollViewController {

    // MARK: Components
    
    private(set) lazy var addContactView: AddContactView = {
        let view = AddContactView()
        return view
    }()
    
    private var imagePicker: ImagePicker
    
    private var keyboardController = KeyboardController()
    
    weak var delegate: AddContactViewControllerDelegate?
    
    private let mode: Mode
    
    init(mode: Mode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        
        imagePicker = ImagePicker()
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        switch mode {
        case .new:
            title = "contacts-add".localized
            return
        case let .edit(contact):
            title = "contacts-edit".localized
            
            addContactView.addContactButton.setTitle("contacts-edit-button".localized, for: .normal)
            
            addContactView.userInformationView.contactNameInputView.inputTextField.text = contact.name
            
            if let address = contact.address {
                addContactView.userInformationView.algorandAddressInputView.value = address
            }
            
            if let imageData = contact.image,
                let image = UIImage(data: imageData) {
                let resizedImage = image.convert(to: CGSize(width: 108.0, height: 108.0))
                
                addContactView.userInformationView.userImageView.image = resizedImage
            }
        }
    }
    
    override func setListeners() {
        super.setListeners()
        
        keyboardController.beginTracking()
    }
    
    override func linkInteractors() {
        keyboardController.dataSource = self
        addContactView.delegate = self
        scrollView.touchDetectingDelegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        contentView.addSubview(addContactView)
        
        addContactView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: AddContactViewDelegate

extension AddContactViewController: AddContactViewDelegate {
    
    func addContactViewDidTapAddImageButton(_ addContactView: AddContactView) {
        imagePicker.delegate = self
        imagePicker.present(from: self)
    }
    
    func addContactViewDidTapAddContactButton(_ addContactView: AddContactView) {
        guard let name = addContactView.userInformationView.contactNameInputView.inputTextField.text,
            !name.isEmpty else {
                displaySimpleAlertWith(title: "title-error".localized, message: "contacts-name-validation-error".localized)
                return
        }
        
        guard let address = addContactView.userInformationView.algorandAddressInputView.inputTextView.text,
            !address.isEmpty,
            address.isValidatedAddress() else {
                displaySimpleAlertWith(title: "title-error".localized, message: "contacts-address-validation-error".localized)
                return
        }
        
        var keyedValues: [String: Any] = [
            Contact.CodingKeys.name.rawValue: name,
            Contact.CodingKeys.address.rawValue: address
        ]
        
        if let placeholderImage = img("icon-user-placeholder-big"),
            let image = addContactView.userInformationView.userImageView.image,
            let imageData = image.jpegData(compressionQuality: 1.0) ?? image.pngData(),
            image != placeholderImage {
            
            keyedValues[Contact.CodingKeys.image.rawValue] = imageData
        }
        
        switch mode {
        case .new:
            addContact(with: keyedValues)
        case let .edit(contact):
            edit(contact, with: keyedValues)
        }
    }
    
    private func addContact(with values: [String: Any]) {
        Contact.create(entity: Contact.entityName, with: values) { result in
            switch result {
            case let .result(object: object):
                guard let contact = object as? Contact else {
                    return
                }
                
                NotificationCenter.default.post(
                    name: Notification.Name.ContactAddition,
                    object: self,
                    userInfo: nil
                )
                
                self.delegate?.addContactViewController(self, didSave: contact)
                
                self.closeScreen(by: .pop)
            default:
                break
            }
        }
    }
    
    private func edit(_ contact: Contact, with values: [String: Any]) {
        contact.update(entity: Contact.entityName, with: values) { result in
            switch result {
            case let .result(object: object):
                guard let contact = object as? Contact else {
                    return
                }
                
                self.delegate?.addContactViewController(self, didSave: contact)
                
                self.closeScreen(by: .pop)
            default:
                break
            }
        }
    }
    
    func addContactViewDidTapQRCodeButton(_ addContactView: AddContactView) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displaySimpleAlertWith(title: "qr-scan-error-title".localized, message: "qr-scan-error-message".localized)
            return
        }
        
        guard let qrScannerViewController = open(.qrScanner, by: .push) as? QRScannerViewController else {
            return
        }
        
        qrScannerViewController.delegate = self
    }
}

// MARK: ImagePickerDelegate

extension AddContactViewController: ImagePickerDelegate {
    
    func imagePicker(didPick image: UIImage, withInfo info: [String: Any]) {
        let resizedImage = image.convert(to: CGSize(width: 108.0, height: 108.0))
        addContactView.userInformationView.userImageView.image = resizedImage
    }
}

// MARK: KeyboardControllerDataSource

extension AddContactViewController: KeyboardControllerDataSource {
    
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return addContactView.userInformationView.algorandAddressInputView
    }
    
    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }
    
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return 15.0
    }
}

// MARK: QRScannerViewControllerDelegate

extension AddContactViewController: QRScannerViewControllerDelegate {
    
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, then handler: EmptyHandler?) {
        
        guard qrText.mode == .address else {
            displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-address-message".localized) { _ in
                if let handler = handler {
                    handler()
                }
            }
            return
        }
        
        addContactView.userInformationView.algorandAddressInputView.value = qrText.text
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, then handler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = handler {
                handler()
            }
        }
    }
}

// MARK: Mode

extension AddContactViewController {
    
    enum Mode {
        case new
        case edit(contact: Contact)
    }
}

// MARK: TouchDetectingScrollViewDelegate

extension AddContactViewController: TouchDetectingScrollViewDelegate {
    
    func scrollViewDidDetectTouchEvent(scrollView: TouchDetectingScrollView, in point: CGPoint) {
        if addContactView.addContactButton.frame.contains(point) {
            return
        }
        
        contentView.endEditing(true)
    }
}
