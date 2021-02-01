//
//  AccountStatus.swift

import Magpie

enum AccountStatus: String, Model {
    case offline = "Offline"
    case online = "Online"
    case notParticipating = "NotParticipating"
}

extension AccountStatus: Encodable { }
