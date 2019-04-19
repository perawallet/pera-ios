//
//  PassPhraseBackUpViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassPhraseBackUpViewController: BaseScrollViewController {
    
    private var mnemonics: [String]? {
        guard let session = self.session else {
            return nil
        }
        
        let mnemonics = session.mnemonics(forAccount: "temp")
        
        return mnemonics
    }
    
    // MARK: Components
    
    private lazy var passPhraseBackUpView: PassPhraseBackUpView = {
        let view = PassPhraseBackUpView()
        return view
    }()
    
    private var maxCellWidth: CGFloat?
    
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
        passPhraseBackUpView.passphraseCollectionView.delegate = self
        passPhraseBackUpView.passphraseCollectionView.dataSource = self
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
    }
}

// MARK: UICollectionViewDataSource

extension PassPhraseBackUpViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let mnemonics = mnemonics else {
            return 0
        }
        
        return mnemonics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PassphraseBackUpCell.reusableIdentifier,
            for: indexPath) as? PassphraseBackUpCell else {
                fatalError("Index path is out of bounds")
        }
        
        cell.contextView.numberLabel.text = "\(indexPath.row + 1)"
        
        guard let mnemonics = mnemonics else {
            return cell
        }
        
        cell.contextView.phraseLabel.text = mnemonics[indexPath.row]
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension PassPhraseBackUpViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        return CGSize(width: collectionView.frame.width / 3.0, height: 22.0)
    }
}

// MARK: PassPhraseBackUpViewDelegate

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
