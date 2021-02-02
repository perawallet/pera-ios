//
//  Acount+Signature.swift

import Magpie

extension Account {
    enum SignatureType: String, Model {
        case sig = "sig"
        case multiSig = "msig"
        case logicSig = "lsig"
    }
}

extension Account.SignatureType: Encodable { }
