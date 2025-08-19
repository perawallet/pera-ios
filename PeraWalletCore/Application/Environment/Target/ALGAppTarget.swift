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

//   ALGAppTarget.swift

import Foundation
import MacaroonApplication
import MacaroonUtils

public final class ALGAppTarget: MacaroonApplication.AppTarget {
    public let app: App
    public let deeplinkConfig: ALGDeeplinkConfig
    public let walletConnectConfig: ALGWalletConnectConfig
    public let universalLinkConfig: ALGUniversalLinkConfig
    /// <todo>
    /// Let's name it as `isStore` in 'Macaroon' later.
    public let isProduction: Bool
    
    public let bundleIdentifier = getBundleIdentifier()
    public let displayName = getDisplayName()
    public let version = getVersion()
    
    public static var current: ALGAppTarget!
    
    private enum CodingKeys: CodingKey {
        case app
        case deeplinkConfig
        case walletConnectConfig
        case universalLinkConfig
        case isProduction
    }
    
    public static func setup() {
        current = load(fromResource: "Config")
    }
}

extension ALGAppTarget {
    public enum App:
        RawRepresentable,
        CaseIterable,
        Decodable {
        case beta
        case staging
        case store
        
        public var rawValue: String {
            switch self {
            case .beta: return "pera-beta"
            default: return "pera"
            }
        }
        
        public static let allCases: [ALGAppTarget.App] = [
            .beta,
            .staging,
            .store
        ]
        
        public init?(
            rawValue: String
        ) {
            let foundCase = Self.allCases.first(matching: (\.rawValue, rawValue))
            self = foundCase ?? .store
        }
        
        public static func == (lhs: ALGAppTarget.App, rhs: ALGAppTarget.App) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
}
