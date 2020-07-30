//
//  Participation.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.10.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class Participation: Model {
    var selectionParticipationKey: String?
    var voteParticipationKey: String?
    
    enum CodingKeys: String, CodingKey {
        case selectionParticipationKey = "selection-participation-key"
        case voteParticipationKey = "vote-participation-key"
    }
}

extension Participation: Encodable { }
