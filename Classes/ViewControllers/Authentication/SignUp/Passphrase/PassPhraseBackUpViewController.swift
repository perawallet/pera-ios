//
//  PassPhraseBackUpViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassPhraseBackUpViewController: PassphraseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generatePrivateKey()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "new-account-title".localized
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupPassphraseViewLayout()
    }
    
    override func passphraseViewDidTapActionButton(_ passphraseView: PassphraseView) {
        open(.passPhraseVerify, by: .push)
    }
}

extension PassPhraseBackUpViewController {
    private func setupPassphraseViewLayout() {
        contentView.addSubview(passphraseView)
        
        passphraseView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension PassPhraseBackUpViewController {
    private func generatePrivateKey() {
        guard let session = self.session,
            let privateKey = session.generatePrivateKey() else {
                return
        }
        
        session.savePrivate(privateKey, for: address)
    }
}
