//
//  AlertViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AlertViewModel {
    func configure(_ alertView: AlertView, with configurator: AlertViewConfigurator) {
        alertView.titleLabel.text = configurator.title
        alertView.explanationLabel.attributedText = configurator.explanation.attributed([.lineSpacing(1.2)])
        alertView.explanationLabel.textAlignment = .center
        alertView.imageView.image = configurator.image
        
        if let destructiveAlertView = alertView as? DestructiveAlertView {
            if let actionTitle = configurator.actionTitle {
                destructiveAlertView.actionButton.setTitle(actionTitle, for: .normal)
            }
            
            if let actionImage = configurator.actionImage {
                destructiveAlertView.actionButton.setBackgroundImage(actionImage, for: .normal)
            }
            
            return
        } else if let defaultAlertView = alertView as? DefaultAlertView,
            configurator.actionTitle != nil {
            if let actionTitle = configurator.actionTitle {
                defaultAlertView.doneButton.setAttributedTitle(
                    actionTitle.attributed([.letterSpacing(1.20), .textColor(.white)]),
                    for: .normal
                )
            }
            
            if let actionImage = configurator.actionImage {
                defaultAlertView.doneButton.setBackgroundImage(actionImage, for: .normal)
            }
        }
    }
}
