//
//  IndexerError.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

class IndexerError: Model {
    let message: String
}

extension IndexerError {
    func containsAccount(_ address: String) -> Bool {
        return message.contains(address)
    }
}
