//
//  PassphraseMnemonicViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.02.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import UIKit

class PassphraseMnemonicViewModel {
    private(set) var phrase: String?

    init(mnemonic: String) {
        setPhrase(from: mnemonic)
    }

    private func setPhrase(from mnemonic: String) {
        phrase = mnemonic
    }
}
