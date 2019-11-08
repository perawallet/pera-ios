//
//  PassphraseDisplayViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassphraseDisplayViewController: PassphraseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let topInset: CGFloat = 30.0
        let bottomInset: CGFloat = 20.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
    
    private enum Colors {
        static let backgroundColor = rgba(0.04, 0.05, 0.07, 0.6)
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
        passphraseView.layer.cornerRadius = 10.0
    }

    override func prepareLayout() {
        super.prepareLayout()
        
        setupPassphraseViewLayout()
        adjustPassphraseViewForDisplayMode()
    }
    
    override func passphraseViewDidTapActionButton(_ passphraseView: PassphraseView) {
        dismissScreen()
    }
}

extension PassphraseDisplayViewController {
    private func setupPassphraseViewLayout() {
        view.addSubview(passphraseView)
        
        passphraseView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.center.equalToSuperview()
        }
    }
    
    private func adjustPassphraseViewForDisplayMode() {
        passphraseView.titleLabel.text = "view-pass-phrase-title".localized
        passphraseView.actionButton.setAttributedTitle(
            "title-ok".localized.attributed([.letterSpacing(1.20), .textColor(.white)]),
            for: .normal
        )
        passphraseView.warningContainerView.isHidden = true
        passphraseView.warningLabel.isHidden = true
        
        passphraseView.titleLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
        
        passphraseView.actionButton.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(passphraseView.passphraseContainerView.snp.bottom).offset(layout.current.topInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
}
