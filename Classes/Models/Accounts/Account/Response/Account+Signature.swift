//
//  Acount+Signature.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.12.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

extension Account {
    enum SignatureType: String, Model {
        case sig = "sig"
        case multiSig = "msig"
        case logicSig = "lsig"
    }
}

extension Account.SignatureType: Encodable { }
