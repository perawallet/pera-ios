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
            cell.contextView.assetNameView.setName("asset-algos-title".localized)
            cell.contextView.assetNameView.removeUnitName()
        } else {
            guard let account = contactAccount else {
                return
            }
            
            let assetDetail = account.assetDetails[indexPath.item - 1]
            
            if !assetDetail.isVerified {
                cell.contextView.assetNameView.removeVerified()
            }
            
            cell.contextView.assetNameView.setId("\(assetDetail.id)")
            
            if assetDetail.hasBothDisplayName() {
                cell.contextView.assetNameView.setAssetName(for: assetDetail)
                return
            }
            
            if assetDetail.hasOnlyAssetName() {
                cell.contextView.assetNameView.setName(assetDetail.assetName)
                cell.contextView.assetNameView.removeUnitName()
                return
            }
            
            if assetDetail.hasOnlyUnitName() {
                cell.contextView.assetNameView.setName(assetDetail.unitName)
                cell.contextView.assetNameView.removeName()
                return
            }
            
            if assetDetail.hasNoDisplayName() {
                cell.contextView.assetNameView.setName("title-unknown".localized)
                cell.contextView.assetNameView.nameLabel.textColor = Colors.General.unknown
                cell.contextView.assetNameView.removeUnitName()
                return
            }
        }
    }
}
