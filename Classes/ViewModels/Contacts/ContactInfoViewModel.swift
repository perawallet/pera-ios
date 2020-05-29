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
            let resizedImage = image.convert(to: CGSize(width: 88.0, height: 88.0))
            userInformationView.userImageView.image = resizedImage
        }
        
        userInformationView.setAddButtonHidden(true)
        userInformationView.contactNameInputView.inputTextField.text = contact.name
        
        if let address = contact.address {
            userInformationView.algorandAddressInputView.value = address
        }
    }
    
    func configure(_ cell: ContactAssetCell, at indexPath: IndexPath, with contactAccount: Account?) {
        if indexPath.item == 0 {
            cell.contextView.assetNameView.removeId()
            cell.contextView.assetNameView.nameLabel.text = "asset-algos-title".localized
            cell.contextView.assetNameView.setVerified(true)
        } else {
            guard let account = contactAccount else {
                return
            }
            
            let assetDetail = account.assetDetails[indexPath.item - 1]
            cell.contextView.assetNameView.setAssetName(for: assetDetail)
        }
    }
}
