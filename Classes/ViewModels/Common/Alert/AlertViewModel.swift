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
        alertView.explanationLabel.attributedText = configurator.explanation.attributed([.lineSpacing(1.5)])
        alertView.explanationLabel.textAlignment = .center
        alertView.imageView.image = configurator.image
        
        guard let destructiveAlertView = alertView as? DestructiveAlertView else {
            return
        }
        
        destructiveAlertView.actionButton.setTitle(configurator.actionTitle, for: .normal)
    }
}
