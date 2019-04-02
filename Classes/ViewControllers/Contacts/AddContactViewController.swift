//
//  AddContactViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AddContactViewController: BaseScrollViewController {

    // MARK: Components
    
    private lazy var addContactView: AddContactView = {
        let view = AddContactView()
        return view
    }()
    
    private lazy var imagePicker = ImagePicker(viewController: self)
    
    private var keyboardController = KeyboardController()
    
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
        // TODO: Save contact and reload listing
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
