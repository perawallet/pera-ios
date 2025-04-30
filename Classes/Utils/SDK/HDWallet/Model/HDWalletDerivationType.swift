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
//  HDWalletDerivationType.swift

import Foundation
import x_hd_wallet_api

enum HDWalletDerivationType: Codable {
    case peikert
    case bip32
    
    /// Converts to BIP32DerivationType
    var toBIP32DerivationType: BIP32DerivationType {
        switch self {
        case .peikert:
            return .Peikert
        case .bip32:
            return .Khovratovich
        }
    }
    
    /// Creates an HDWalletDerivationType from BIP32DerivationType
    /// - Parameter bip32Type: The BIP32DerivationType to convert from
    /// - Returns: The corresponding HDWalletDerivationType
    static func from(_ bip32Type: BIP32DerivationType) -> HDWalletDerivationType {
        switch bip32Type {
        case .Peikert:
            return .peikert
        case .Khovratovich:
            return .bip32
        @unknown default:
            return .peikert
        }
    }
} 
