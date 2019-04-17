//
//  PassPhraseBackUpViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

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
        
        configureAccountAppearance()
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

// MARK: - Helpers
extension PassPhraseBackUpViewController {
    func configureAccountAppearance() {
        guard let session = self.session,
            let privateKey = session.generatePrivateKey() else {
                return
        }
        
        session.savePrivate(privateKey, forAccount: "temp")
        
        let mnemonics = session.mnemonics(forAccount: "temp")
        
        var mnemonicsWithNumbers = [NSAttributedString]()
        
        for (index, mnemonic) in mnemonics.enumerated() {
            let attributedIndex = "\(index + 1)".attributed(
                [.textColor(SharedColors.blue),
                 .font(UIFont.font(.opensans, withWeight: .bold(size: 12.0))),
                 .lineSpacing(1.5)]
            )
            mnemonicsWithNumbers.append(attributedIndex)
            
            let attributedMnemonic = mnemonic.attributed(
                [.textColor(SharedColors.black),
                 .font(UIFont.font(.opensans, withWeight: .semiBold(size: 17.0))),
                 .lineSpacing(1.5)]
            )
            mnemonicsWithNumbers.append(attributedMnemonic)
            
            mnemonicsWithNumbers.append(" ".attributed([.lineSpacing(1.5)]))
        }
        
        passPhraseBackUpView.passPhraseLabel.attributedText = mnemonicsWithNumbers.join(with: "".attributed())
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

        open(.qrGenerator(title: nil, text: text, mode: .mnemonic), by: .present)
    }
}
