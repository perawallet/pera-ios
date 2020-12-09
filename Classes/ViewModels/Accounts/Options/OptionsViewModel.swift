//
//  OptionsViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class OptionsViewModel {
    func configure(_ cell: OptionsCell, with option: OptionsViewController.Options) {
        switch option {
        case .rekey:
            cell.contextView.iconImageView.image = img("icon-options-rekey")
            cell.contextView.optionLabel.text = "options-rekey".localized
        case .rekeyInformation:
            cell.contextView.iconImageView.image = img("icon-qr")
            cell.contextView.optionLabel.text = "options-auth-account".localized
        case .removeAsset:
            cell.contextView.iconImageView.image = img("icon-trash")
            cell.contextView.optionLabel.text = "options-remove-assets".localized
        case .passphrase:
            cell.contextView.iconImageView.image = img("icon-lock")
            cell.contextView.optionLabel.text = "options-view-passphrase".localized
        case .edit:
            cell.contextView.iconImageView.image = img("icon-edit-account")
            cell.contextView.optionLabel.text = "options-edit-account-name".localized
        case .removeAccount:
            cell.contextView.iconImageView.image = img("icon-remove-account")
            cell.contextView.optionLabel.text = "options-remove-account".localized
            cell.contextView.optionLabel.textColor = Colors.General.error
        }
    }
}
