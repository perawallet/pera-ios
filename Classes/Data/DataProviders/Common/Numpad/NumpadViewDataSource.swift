//
//  NumpadViewDataSource.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class NumpadViewDataSource: NSObject, UICollectionViewDataSource {
    
    private let viewModel = NumpadCellViewModel()
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = viewModel.dequeueCell(in: collectionView, at: indexPath)
        
        if let cell = cell as? NumpadNumericCell {
            viewModel.configure(cell, at: indexPath)
        }
        
        return cell
    }
}
