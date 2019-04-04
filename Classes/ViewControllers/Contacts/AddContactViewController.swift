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
    
    private lazy var addContactView: AddContactView = {
        let view = AddContactView()
        return view
    }()
    
    private lazy var imagePicker = ImagePicker(viewController: self)
    
    private var keyboardController = KeyboardController()
    
    weak var delegate: AddContactViewControllerDelegate?
    
    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "contacts-add".localized
    }
    
    override func setListeners() {
        super.setListeners()
        
        keyboardController.beginTracking()
    }
    
    override func linkInteractors() {
        keyboardController.dataSource = self
        addContactView.delegate = self
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
        imagePicker.present()
    }
    
    func addContactViewDidTapAddContactButton(_ addContactView: AddContactView) {
        guard let name = addContactView.userInformationView.contactNameInputView.inputTextField.text,
            let address = addContactView.userInformationView.algorandAddressInputView.inputTextView.text,
            !address.isEmpty,
            address.isValidatedAdress() else {
                displaySimpleAlertWith(title: "title-error".localized, message: "contacts-address-validation-error".localized)
                return
        }
        
        var keyedValues: [String: Any] = [
            Contact.CodingKeys.name.rawValue: name,
            Contact.CodingKeys.address.rawValue: address
        ]
        
        if let image = addContactView.userInformationView.userImageView.image?.pngData() {
            keyedValues[Contact.CodingKeys.image.rawValue] = image
        }
        
        Contact.create(entity: Contact.entityName, with: keyedValues) { result in
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
        let resizedImage = image.convert(to: CGSize(width: 108.0, height: 108.0), scale: UIScreen.main.scale)
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
    
    func qRScannerViewController(_ controller: QRScannerViewController, didRead qrCode: String) {
        
        addContactView.userInformationView.algorandAddressInputView.value = qrCode
    }
}
