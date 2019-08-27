//
//  NumpadCellViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class NumpadCellViewModel {
    
    func dequeueCell(in collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 11 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NumpadDeleteCell.reusableIdentifier,
                for: indexPath) as? NumpadDeleteCell else {
                    fatalError("Index path is out of bounds")
            }
            
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NumpadNumericCell.reusableIdentifier,
            for: indexPath) as? NumpadNumericCell else {
                fatalError("Index path is out of bounds")
        }
        
        return cell
    }
    
    func configure(_ cell: NumpadNumericCell, at indexPath: IndexPath) {
        if indexPath.item == 9 {
            cell.contextView.value = .number(nil)
            return
        }
        
        if indexPath.item == 10 {
            cell.contextView.value = .number("0")
            return
        }
        
        cell.contextView.value = .number("\(indexPath.item + 1)")
    }
}
