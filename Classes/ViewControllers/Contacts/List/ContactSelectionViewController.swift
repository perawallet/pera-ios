//
//  ContactSelectionViewController.swift

import UIKit

class ContactSelectionViewController: ContactsViewController {
    
    override var shouldShowNavigationBar: Bool {
        return true
    }
    
    override func configureNavigationBarAppearance() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "contacts-title".localized
        removeHeader()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ContactSelectionCell.reusableIdentifier,
            for: indexPath) as? ContactSelectionCell else {
                fatalError("Index path is out of bounds")
        }
        
        configure(cell, at: indexPath)
        return cell
    }
}
