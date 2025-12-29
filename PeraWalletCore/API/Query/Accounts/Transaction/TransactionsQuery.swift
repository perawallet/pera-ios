// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  TransactionsQuery.swift

import MagpieCore

struct TransactionsQuery: ObjectQuery {
    let limit: Int?
    let from: String?
    let to: String?
    let next: String?
    let assetId: String?
    let transactionType: String?
    
    var queryParams: [APIQueryParam] {
        var params: [APIQueryParam] = []
        if let limit = limit {
            params.append(.init(.limit, limit))
        }
        
        if let from = from,
            let to = to {
            params.append(.init(.afterTime, from))
            params.append(.init(.beforeTime, to))
        }
        
        if let next = next {
            params.append(.init(.next, next))
        }
        
        if let assetId = assetId {
            params.append(.init(.asset, assetId))
        }

        params.append(.init(.transactionType, transactionType, .setIfPresent))
        
        return params
    }
}

public struct AccountQueryOptions: OptionSet {
    public let rawValue: Int

    public static let includeAll = AccountQueryOptions(rawValue: 1 << 0)
    public static let excludeAll = AccountQueryOptions(rawValue: 1 << 1)
    public static let createdAssets = AccountQueryOptions(rawValue: 1 << 2)
    public static let createdApps = AccountQueryOptions(rawValue: 1 << 3)
    public static let assets = AccountQueryOptions(rawValue: 1 << 4)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct AccountQuery: ObjectQuery {
    
    public var options: AccountQueryOptions
    
    public init(options: AccountQueryOptions) {
        self.options = options
    }
    
    public var queryParams: [APIQueryParam] {
        var params: [APIQueryParam] = []
        
        if options.contains(.includeAll) {
            params.append(.init(.includesAll, true))
        }
        
        let excludeOptions: [(AccountQueryOptions, String)] = [
            (.createdAssets, "created-assets"),
            (.createdApps, "created-apps"),
            (.assets, "assets")
        ]
        
        let exclusions = options.contains(.excludeAll) ? ["all"] : excludeOptions.filter { options.contains($0.0) }.map { $0.1 }
        
        if !exclusions.isEmpty {
            params.append(.init(.exclude, exclusions.joined(separator: ",")))
        }
        
        return params
    }
}
