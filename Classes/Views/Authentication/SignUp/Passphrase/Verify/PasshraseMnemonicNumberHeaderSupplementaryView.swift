//
//  PasshraseMnemonicNumberHeaderSupplementaryView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.02.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import UIKit

class PasshraseMnemonicNumberHeaderSupplementaryView: BaseSupplementaryView<PasshraseMnemonicNumberHeaderView> {

    func bind(_ viewModel: PasshraseMnemonicNumberHeaderViewModel) {
        contextView.bind(viewModel)
    }
}
