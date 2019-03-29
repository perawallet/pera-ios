//
//  PassPhraseBackUpViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Crypto

class PassPhraseBackUpViewController: BaseScrollViewController {
    
    // MARK: Components
    
    private lazy var passPhraseBackUpView: PassPhraseBackUpView = {
        let view = PassPhraseBackUpView()
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "new-account-title".localized
        
        if let privateKey = CryptoGenerateSK() {
            self.session?.savePrivate(privateKey, forAccount: "temp")
            
            let mnemonics = self.session?.mnemonics(forAccount: "temp") ?? []
            
            print(mnemonics.joined(separator: " "))
            
            passPhraseBackUpView.passPhraseLabel.attributedText = mnemonics.joined(separator: " ")
                .attributed([.lineSpacing(1.5)])
        }
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        contentView.addSubview(passPhraseBackUpView)
        
        passPhraseBackUpView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func linkInteractors() {
        passPhraseBackUpView.delegate = self
    }
}

extension PassPhraseBackUpViewController: PassPhraseBackUpViewDelegate {
    
    func passPhraseBackUpViewDidTapShareButton(_ passPhraseBackUpView: PassPhraseBackUpView) {
        let mnemonics = self.session?.mnemonics(forAccount: "temp") ?? []
        
        let sharedItem = [mnemonics.joined(separator: " ")]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func passPhraseBackUpViewDidTapVerifyButton(_ passPhraseBackUpView: PassPhraseBackUpView) {
        open(.passPhraseVerify, by: .push)
    }
    
    func passPhraseBackUpViewDidTapQrButton(_ passPhraseBackUpView: PassPhraseBackUpView) {
        let mnemonics = self.session?.mnemonics(forAccount: "temp") ?? []
        let text = mnemonics.joined(separator: " ")

        open(.qrGenerator(text: text, mode: .mnemonic), by: .present)
    }
}
