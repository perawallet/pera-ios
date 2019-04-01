//
//  AddContactViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AddContactViewController: BaseViewController {

    // MARK: Components
    
    private lazy var addContactView: AddContactView = {
        let view = AddContactView()
        return view
    }()
    
    private lazy var imagePicker = ImagePicker(viewController: self)
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "contacts-add".localized
    }
    
    override func linkInteractors() {
        addContactView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        view.addSubview(addContactView)
        
        addContactView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

    }
}

// MARK: ImagePickerDelegate

extension AddContactViewController: ImagePickerDelegate {
    
    func imagePicker(didPick image: UIImage, withInfo info: [String: Any]) {
        let resizedImage = image.convert(to: CGSize(width: 108.0, height: 108.0), scale: UIScreen.main.scale)
        addContactView.userInformationView.userImageView.image = resizedImage
    }
}
