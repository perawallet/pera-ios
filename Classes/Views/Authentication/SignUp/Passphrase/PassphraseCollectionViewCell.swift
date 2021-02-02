//
//  PassPhraseCollectionViewCell.swift

import UIKit

class PassphraseCollectionViewCell: BaseCollectionViewCell<PassphraseMnemonicView> {
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.setMode(.idle, animated: false)
    }
}
