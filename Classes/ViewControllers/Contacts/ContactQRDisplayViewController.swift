//
//  ContactQRDisplayViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactQRDisplayViewController: BaseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
    }
    
    private enum Colors {
        static let backgroundColor = rgba(0.04, 0.05, 0.07, 0.6)
    }
    
    private let layout = Layout<LayoutConstants>()

    // MARK: Components
    
    private lazy var contactQRDisplayView: ContactQRDisplayView = {
        let view = ContactQRDisplayView(address: contact.address ?? "")
        return view
    }()
    
    // MARK: Initialization
    
    private let contact: Contact
    
    init(contact: Contact, configuration: ViewControllerConfiguration) {
        self.contact = contact
        
        super.init(configuration: configuration)
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
        
        contactQRDisplayView.nameLabel.text = contact.name
        contactQRDisplayView.addressLabel.text = contact.address
        
        if let imageData = contact.image,
            let image = UIImage(data: imageData) {
            
            let resizedImage = image.convert(to: CGSize(width: 50.0, height: 50.0), scale: UIScreen.main.scale)
            
            contactQRDisplayView.userImageView.image = resizedImage
        }
    }
    
    override func linkInteractors() {
        contactQRDisplayView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        view.addSubview(contactQRDisplayView)
        
        contactQRDisplayView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.center.equalToSuperview()
        }
    }
}

// MARK: ContactQRDisplayViewDelegate

extension ContactQRDisplayViewController: ContactQRDisplayViewDelegate {
    
    func contactQRDisplayViewDidTapCloseButton(_ contactQRDisplayView: ContactQRDisplayView) {
        dismissScreen()
    }
}
