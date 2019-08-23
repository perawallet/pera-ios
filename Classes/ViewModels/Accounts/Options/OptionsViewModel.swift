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
        case .showQR:
            cell.contextView.iconImageView.image = img("icon-qr-code-purple")
            cell.contextView.optionLabel.text = "options-show-qr".localized
        case .setDefault:
            cell.contextView.iconImageView.image = img("icon-default-account")
            cell.contextView.optionLabel.text = "options-default-account".localized
        case .passPhrase:
            cell.contextView.iconImageView.image = img("icon-show-passphrase")
            cell.contextView.optionLabel.text = "options-view-passphrase".localized
        case .edit:
            cell.contextView.iconImageView.image = img("icon-edit-account")
            cell.contextView.optionLabel.text = "options-edit-account-name".localized
        case .remove:
            cell.contextView.iconImageView.image = img("icon-remove-account")
            cell.contextView.optionLabel.text = "options-remove-account".localized
        }
    }
}
