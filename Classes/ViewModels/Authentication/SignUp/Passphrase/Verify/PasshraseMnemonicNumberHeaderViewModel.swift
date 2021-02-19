//
//  PasshraseMnemonicNumberHeaderViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.02.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Foundation

class PasshraseMnemonicNumberHeaderViewModel {
    private(set) var number: String?

    init(order: Int) {
        setNumber(from: order)
    }

    private func setNumber(from order: Int) {
        number = "passphrase-verify-select-word".localized(params: "\(order + 1)")
    }
}
