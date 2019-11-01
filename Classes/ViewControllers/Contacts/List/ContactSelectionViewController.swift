//
//  ContactSelectionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactSelectionViewController: ContactsViewController {
    
    override func configureNavigationBarAppearance() {
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
