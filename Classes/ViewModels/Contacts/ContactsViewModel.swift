//
//  ContactsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactsViewModel {
    private(set) var image: UIImage?
    private(set) var name: String?
    private(set) var address: String?

    init(contact: Contact, imageSize: CGSize) {
        setImage(from: contact, with: imageSize)
        setName(from: contact)
        setAddress(from: contact)
    }

    private func setImage(from contact: Contact, with imageSize: CGSize) {
        if let imageData = contact.image,
            let image = UIImage(data: imageData) {
            self.image = image.convert(to: imageSize)
        }
    }

    private func setName(from contact: Contact) {
        name = contact.name
    }

    private func setAddress(from contact: Contact) {
        address = contact.address?.shortAddressDisplay()
    }
}
