//
//  PassphraseDisplayViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassphraseDisplayViewController: BaseViewController {
    
    var mnemonics: [String]? {
        guard let session = self.session else {
            return nil
        }
        let mnemonics = session.mnemonics(forAccount: address)
        return mnemonics
    }
    
    private var address: String
    
    private lazy var passphraseDisplayView = PassphraseDisplayView()
    
    init(address: String, configuration: ViewControllerConfiguration) {
        self.address = address
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            self?.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func configureAppearance() {
        view.backgroundColor = SharedColors.secondaryBackground
        title = "options-view-passphrase".localized
        setSecondaryBackgroundColor()
    }
    
    override func linkInteractors() {
        passphraseDisplayView.delegate = self
        passphraseDisplayView.passphraseCollectionView.delegate = self
        passphraseDisplayView.passphraseCollectionView.dataSource = self
    }

    override func prepareLayout() {
        setupPassphraseViewLayout()
    }
}

extension PassphraseDisplayViewController {
    private func setupPassphraseViewLayout() {
        view.addSubview(passphraseDisplayView)
        
        passphraseDisplayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension PassphraseDisplayViewController: UICollectionViewDataSource {
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
        
        cell.contextView.numberLabel.text = "\(indexPath.item + 1)."
        
        guard let mnemonics = mnemonics else {
            return cell
        }
        
        cell.contextView.phraseLabel.text = mnemonics[indexPath.item]
        return cell
    }
}

extension PassphraseDisplayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3.0, height: 22.0)
    }
}

extension PassphraseDisplayViewController: PassphraseDisplayViewDelegate {
    func passphraseViewDidOpenQR(_ passphraseDisplayView: PassphraseDisplayView) {
        let mnemonics = self.session?.mnemonics(forAccount: address) ?? []
        let mnemonicText = mnemonics.joined(separator: " ")
        open(.qrGenerator(title: "qr-creation-title".localized, address: address, mnemonic: mnemonicText, mode: .mnemonic), by: .present)
    }
    
    func passphraseViewDidShare(_ passphraseDisplayView: PassphraseDisplayView) {
        let mnemonics = self.session?.mnemonics(forAccount: address) ?? []
        
        let sharedItem = [mnemonics.joined(separator: " ")]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        
        if let navigationController = navigationController {
            navigationController.present(activityViewController, animated: true, completion: nil)
        } else {
            present(activityViewController, animated: true, completion: nil)
        }
    }
}
