//
//  LedgerDetail.swift

import Magpie

class LedgerDetail: Model {
    let id: UUID?
    let name: String?
    var indexInLedger: Int?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        indexInLedger = try container.decodeIfPresent(Int.self, forKey: .indexInLedger)
    }
    
    init(id: UUID?, name: String?, indexInLedger: Int?) {
        self.id = id
        self.name = name
        self.indexInLedger = indexInLedger
    }
}

extension LedgerDetail {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case indexInLedger = "index"
    }
}
