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
//  AccountInformation.swift

import UIKit

public typealias PublicKey = String
public typealias RekeyDetail = [PublicKey: LedgerDetail]

public final class AccountInformation: Codable {
    
    public let address: String
    public var name: String
    public var ledgerDetail: LedgerDetail?
    public var receivesNotification: Bool
    public var rekeyDetail: RekeyDetail?
    public var preferredOrder: Int
    public var isBackedUp: Bool
    public var hdWalletAddressDetail: HDWalletAddressDetail?
    public let jointAccountParticipants: [String]?
    public var nfDomain: String?

    static let invalidOrder = -1

    public var isWatchAccount: Bool {
        get {
            return type == .watch
        }
        set {
            type = newValue ? .watch : .standard
        }
    }

    public internal(set) var type: AccountType
    
    public init(
        address: String,
        name: String,
        isWatchAccount: Bool,
        ledgerDetail: LedgerDetail? = nil,
        rekeyDetail: RekeyDetail? = nil,
        receivesNotification: Bool = true,
        preferredOrder: Int? = nil,
        isBackedUp: Bool,
        hdWalletAddressDetail: HDWalletAddressDetail? = nil,
        jointAccountParticipants: [String]? = nil
    ) {
        self.address = address
        self.name = name
        
        if isWatchAccount {
            self.type = .watch
        } else if jointAccountParticipants != nil {
            self.type = .joint
        } else {
            self.type = .standard
        }
        
        self.ledgerDetail = ledgerDetail
        self.receivesNotification = receivesNotification
        self.rekeyDetail = rekeyDetail
        self.preferredOrder = preferredOrder ?? Self.invalidOrder
        self.isBackedUp = isBackedUp
        self.hdWalletAddressDetail = hdWalletAddressDetail
        self.jointAccountParticipants = jointAccountParticipants
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decodeIfPresent(AccountType.self, forKey: .type) ?? .standard
        ledgerDetail = try container.decodeIfPresent(LedgerDetail.self, forKey: .ledgerDetail)
        receivesNotification = try container.decodeIfPresent(Bool.self, forKey: .receivesNotification) ?? true
        rekeyDetail = try container.decodeIfPresent(RekeyDetail.self, forKey: .rekeyDetail)
        preferredOrder = try container.decodeIfPresent(Int.self, forKey: .preferredOrder) ?? Self.invalidOrder
        isBackedUp = try container.decodeIfPresent(Bool.self, forKey: .isBackedUp) ?? true
        hdWalletAddressDetail = try container.decodeIfPresent(HDWalletAddressDetail.self, forKey: .hdWalletAddressDetail)
        jointAccountParticipants = try container.decodeIfPresent([String].self, forKey: .jointAccountParticipants)
        nfDomain = try container.decodeIfPresent(String.self, forKey: .nfDomain)
    }
}

extension AccountInformation {
    public func updateName(_ name: String) {
        self.name = name
    }
    
    public func addRekeyDetail(_ ledgerDetail: LedgerDetail, for address: String) {
        if rekeyDetail != nil {
            self.rekeyDetail?[address] = ledgerDetail
        } else {
            self.rekeyDetail = [address: ledgerDetail]
        }
    }

    public func addRekeyDetail(_ rekeyDetail: RekeyDetail, for address: String) {
        if self.rekeyDetail != nil {
            self.rekeyDetail?[address] = rekeyDetail[address]
        } else {
            self.rekeyDetail = rekeyDetail
        }
    }
}

extension AccountInformation {
    public enum AccountType:
        String,
        Codable {
        case standard = "standard"
        case watch = "watch"
        case ledger = "ledger"
        case joint
        case rekeyed = "rekeyed"
        
        public static func == (lhs: AccountType, rhs: AccountType) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
}

extension AccountInformation {
    public enum CodingKeys: String, CodingKey {
        case address = "address"
        case name = "name"
        case type = "type"
        case ledgerDetail = "ledgerDetail"
        case receivesNotification = "receivesNotification"
        case rekeyDetail = "rekeyDetail"
        case preferredOrder = "preferredOrder"
        case isBackedUp = "isBackedUp"
        case hdWalletAddressDetail = "hdWalletAddressDetail"
        case jointAccountParticipants
        case nfDomain
        
        public static func == (lhs: CodingKeys, rhs: CodingKeys) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }
}

extension AccountInformation: Hashable {
    public static func == (lhs: AccountInformation, rhs: AccountInformation) -> Bool {
        return lhs.address == rhs.address
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }
}
