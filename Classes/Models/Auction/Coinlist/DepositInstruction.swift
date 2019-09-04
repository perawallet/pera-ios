//
//  DepositInstruction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

struct DepositInstruction: Model {
    let type: DepositType
    let amount: Double
    
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension DepositInstruction: Encodable {
}
