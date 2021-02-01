//
//  PaginatedList.swift

import Magpie

class PaginatedList<T: Model>: Model {
    let count: Int
    let next: URL?
    let previous: String?
    let results: [T]

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = try container.decodeIfPresent(Int.self, forKey: .count) ?? 0
        next = try container.decodeIfPresent(URL.self, forKey: .next)
        previous = try container.decodeIfPresent(String.self, forKey: .previous)
        results = try container.decode([T].self, forKey: .results)
    }
}

extension PaginatedList {
    enum CodingKeys: String, CodingKey {
        case count = "count"
        case next = "next"
        case previous = "previous"
        case results = "results"
    }
}
