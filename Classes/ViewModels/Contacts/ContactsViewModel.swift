//
//  ContactsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactsViewModel {
    func configure(_ cell: ContactCell, with contact: Contact) {
        if let imageData = contact.image,
            let image = UIImage(data: imageData) {
            
            let resizedImage = image.convert(to: CGSize(width: 50.0, height: 50.0))
            
            cell.contextView.userImageView.image = resizedImage
        }
        
        cell.contextView.nameLabel.text = contact.name
        cell.contextView.addressLabel.text = contact.address?.shortAddressDisplay()
    }
}
