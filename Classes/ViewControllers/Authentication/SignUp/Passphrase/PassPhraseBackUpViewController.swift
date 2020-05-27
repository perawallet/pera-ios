//
//  PassphraseBackUpViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassphraseBackUpViewController: BaseScrollViewController {
    
    var mnemonics: [String]? {
        guard let session = self.session else {
            return nil
        }
        let mnemonics = session.mnemonics(forAccount: address)
        return mnemonics
    }
    
    private var address: String
    private var maxCellWidth: CGFloat?
    
    private lazy var passphraseView = PassphraseView()
    
    init(address: String, configuration: ViewControllerConfiguration) {
        self.address = address
        super.init(configuration: configuration)
    }
    
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
    
    override func linkInteractors() {
        passphraseView.delegate = self
        passphraseView.passphraseCollectionView.delegate = self
        passphraseView.passphraseCollectionView.dataSource = self
    }
    
    func passphraseViewDidTapActionButton(_ passphraseView: PassphraseView) {
        open(.passphraseVerify, by: .push)
    }
}

extension PassphraseBackUpViewController {
    private func setupPassphraseViewLayout() {
        contentView.addSubview(passphraseView)
        
        passphraseView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension PassphraseBackUpViewController: UICollectionViewDataSource {
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

extension PassphraseBackUpViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3.0, height: 22.0)
    }
}

extension PassphraseBackUpViewController: PassphraseBackUpViewDelegate {
    func passphraseViewDidTapShareButton(_ passphraseView: PassphraseView) {
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
    
    func passphraseViewDidTapQrButton(_ passphraseView: PassphraseView) {
        let mnemonics = self.session?.mnemonics(forAccount: address) ?? []
        let mnemonicText = mnemonics.joined(separator: " ")
        open(.qrGenerator(title: "qr-creation-title".localized, address: address, mnemonic: mnemonicText, mode: .mnemonic), by: .present)
    }
}

extension PassphraseBackUpViewController {
    private func generatePrivateKey() {
        guard let session = self.session,
            let privateKey = session.generatePrivateKey() else {
                return
        }
        
        session.savePrivate(privateKey, for: address)
    }
}
