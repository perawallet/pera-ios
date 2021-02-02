//
//  Participation.swift

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
