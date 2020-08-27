//
//  LedgerDetail.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

class LedgerDetail: Model {
    let id: UUID?
    let name: String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
    }
    
    init(id: UUID?, name: String?) {
        self.id = id
        self.name = name
    }
}

extension LedgerDetail {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
}
