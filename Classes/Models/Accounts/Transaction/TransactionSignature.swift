//
//  TransactionSignature.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

class TransactionSignature: Model {
    let signature: String?
}

extension TransactionSignature {
    enum CodingKeys: String, CodingKey {
        case signature = "sig"
    }
}
