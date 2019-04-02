//
//  ContactInfoViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactInfoViewModel {
    
    func configure(_ userInformationView: UserInformationView, with contact: Contact) {
        if let imageData = contact.image,
            let image = UIImage(data: imageData) {
            
            let resizedImage = image.convert(to: CGSize(width: 108.0, height: 108.0), scale: UIScreen.main.scale)
            
            userInformationView.userImageView.image = resizedImage
        }
        
        userInformationView.addButton.isHidden = true
        userInformationView.contactNameInputView.inputTextField.text = contact.name
        
        // TODO: Configure address input text
        
        if let address = contact.address {
            userInformationView.algorandAddressInputView.value = address
        }
    }
}
