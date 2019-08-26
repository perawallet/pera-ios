//
//  PassphraseViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassphraseViewController: BaseScrollViewController {
    
    var mnemonics: [String]? {
        guard let session = self.session else {
            return nil
        }
        
        let mnemonics = session.mnemonics(forAccount: address)
        
        return mnemonics
    }
    
    private(set) var address: String
    private var maxCellWidth: CGFloat?
    
    private(set) lazy var passphraseView: PassphraseView = {
        let view = PassphraseView()
        return view
    }()
    
    init(address: String, configuration: ViewControllerConfiguration) {
        self.address = address
        super.init(configuration: configuration)
    }
    
    override func linkInteractors() {
        passphraseView.delegate = self
        passphraseView.passphraseCollectionView.delegate = self
        passphraseView.passphraseCollectionView.dataSource = self
    }
    
    func passphraseViewDidTapActionButton(_ passphraseView: PassphraseView) {
        
    }
}

// MARK: UICollectionViewDataSource

extension PassphraseViewController: UICollectionViewDataSource {
    
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

extension PassphraseViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        
        return CGSize(width: collectionView.frame.width / 3.0, height: 22.0)
    }
}

// MARK: PassPhraseBackUpViewDelegate

extension PassphraseViewController: PassPhraseBackUpViewDelegate {
    
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
        let text = mnemonics.joined(separator: " ")
        
        open(.qrGenerator(title: nil, text: text, mode: .mnemonic), by: .present)
    }
}
