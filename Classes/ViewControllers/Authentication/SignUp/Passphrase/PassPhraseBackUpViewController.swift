//
//  PassPhraseBackUpViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassPhraseBackUpViewController: PassphraseViewController {
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "new-account-title".localized
        
        generatePrivateKey()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        contentView.addSubview(passphraseView)
        
        passphraseView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func passphraseViewDidTapActionButton(_ passphraseView: PassphraseView) {
        open(.passPhraseVerify, by: .push)
    }
}

// MARK: - Helpers

extension PassPhraseBackUpViewController {
    
    private func generatePrivateKey() {
        guard let session = self.session,
            let privateKey = session.generatePrivateKey() else {
                return
        }
        
        session.savePrivate(privateKey, forAccount: address)
    }
}
