//
//  OptionsCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class OptionsCell: BaseCollectionViewCell<OptionsContextView> {

    func bind(_ viewModel: OptionsViewModel) {
        contextView.bind(viewModel)
    }
}
