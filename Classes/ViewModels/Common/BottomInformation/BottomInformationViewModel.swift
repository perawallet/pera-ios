//
//  BottomInformationViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BottomInformationViewModel {
    func configure(_ bottomInformationView: BottomInformationView, with configurator: BottomInformationViewConfigurator) {
        bottomInformationView.titleLabel.attributedText = configurator.title.attributed([.lineSpacing(1.2)])
        bottomInformationView.titleLabel.textAlignment = .center
        bottomInformationView.explanationLabel.attributedText = configurator.explanation.attributed([.lineSpacing(1.2)])
        bottomInformationView.explanationLabel.textAlignment = .center
        bottomInformationView.imageView.image = configurator.image
        
        if let bottomInformationView = bottomInformationView as? DefaultBottomInformationView {
            configureDefaultInformationView(bottomInformationView, with: configurator)
            return
        }
        
        if let bottomInformationView = bottomInformationView as? ActionBottomInformationView {
            configureActionInformationView(bottomInformationView, with: configurator)
            return
        }
    }
    
    private func configureDefaultInformationView(
        _ informationView: DefaultBottomInformationView,
        with configurator: BottomInformationViewConfigurator
    ) {
        if let actionTitle = configurator.actionTitle {
            informationView.actionButton.setTitle(actionTitle, for: .normal)
        }
        
        if let actionImage = configurator.actionImage {
            informationView.actionButton.setBackgroundImage(actionImage, for: .normal)
        }
    }
    
    private func configureActionInformationView(
        _ informationView: ActionBottomInformationView,
        with configurator: BottomInformationViewConfigurator
    ) {
        if let actionTitle = configurator.actionTitle {
            informationView.actionButton.setTitle(actionTitle, for: .normal)
        }
        
        if let actionImage = configurator.actionImage {
            informationView.actionButton.setBackgroundImage(actionImage, for: .normal)
        }
        
        informationView.cancelButton.setTitle(configurator.closeTitle, for: .normal)
        
        if let closeBackgroundImage = configurator.closeBackgroundImage {
            informationView.cancelButton.setBackgroundImage(closeBackgroundImage, for: .normal)
        }
    }
}
