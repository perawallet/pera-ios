//
//  PassphraseDisplayViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassphraseDisplayViewController: BaseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let topInset: CGFloat = 30.0
        let bottomInset: CGFloat = 20.0
        let buttonHorizontalInset: CGFloat = 20.0
    }
    
    private enum Colors {
        static let backgroundColor = rgba(0.04, 0.05, 0.07, 0.6)
    }
    
    private var address: String
    
    private let layout = Layout<LayoutConstants>()
    
    init(address: String, configuration: ViewControllerConfiguration) {
        self.address = address
        super.init(configuration: configuration)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
      //  passphraseView.layer.cornerRadius = 10.0
    }

    override func prepareLayout() {
        super.prepareLayout()

        setupPassphraseViewLayout()
    }
    
    func passphraseViewDidTapActionButton(_ passphraseView: PassphraseView) {
        dismissScreen()
    }
}

extension PassphraseDisplayViewController {
    private func setupPassphraseViewLayout() {
//        view.addSubview(passphraseView)
//        
//        passphraseView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
//            make.center.equalToSuperview()
//        }
    }
}
