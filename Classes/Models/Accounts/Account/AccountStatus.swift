//
//  AccountStatus.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

enum AccountStatus: String, Model {
    case offline = "Offline"
    case online = "Online"
    case notParticipating = "NotParticipating"
}

extension AccountStatus: Encodable { }
