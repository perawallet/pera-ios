//
//  HIPListDraft.swift
//  Magpie
//
//  Created by Karasuluoglu on 29.07.2020.
//

import Foundation

public struct HIPListDraft: Query {
    public let queryParams: [URLQueryItem]

    public init(url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        queryParams = components?.queryItems ?? []
    }

    public func encoded() throws -> [URLQueryItem] {
        return queryParams
    }
}
