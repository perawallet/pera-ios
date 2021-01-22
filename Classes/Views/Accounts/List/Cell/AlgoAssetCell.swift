//
//  AlgoAssetCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AlgoAssetCell: BaseCollectionViewCell<AlgoAssetView> {

    func bind(_ viewModel: AlgoAssetViewModel) {
        contextView.bind(viewModel)
    }
}
