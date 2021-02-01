//
//  AccountInformation.swift

import Magpie

typealias PublicKey = String
typealias RekeyDetail = [PublicKey: LedgerDetail]

class AccountInformation: Model {
    let address: String
    var name: String
    var type: AccountType = .standard
    var ledgerDetail: LedgerDetail?
    var receivesNotification: Bool
    var rekeyDetail: RekeyDetail?
    
    init(
        address: String,
        name: String,
        type: AccountType,
        ledgerDetail: LedgerDetail? = nil,
        rekeyDetail: RekeyDetail? = nil,
        receivesNotification: Bool = true
    ) {
        self.address = address
        self.name = name
        self.type = type
        self.ledgerDetail = ledgerDetail
        self.receivesNotification = receivesNotification
        self.rekeyDetail = rekeyDetail
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decodeIfPresent(AccountType.self, forKey: .type) ?? .standard
        ledgerDetail = try container.decodeIfPresent(LedgerDetail.self, forKey: .ledgerDetail)
        receivesNotification = try container.decodeIfPresent(Bool.self, forKey: .receivesNotification) ?? true
        rekeyDetail = try container.decodeIfPresent(RekeyDetail.self, forKey: .rekeyDetail)
    }
}

extension AccountInformation {
    func updateName(_ name: String) {
        self.name = name
    }
    
    func mnemonics() -> [String]? {
        if type == .watch || type == .ledger || type == .rekeyed {
            return nil
        }
        return UIApplication.shared.appConfiguration?.session.mnemonics(forAccount: address)
    }
    
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    func addRekeyDetail(_ ledgerDetail: LedgerDetail, for address: String) {
        if rekeyDetail != nil {
            self.rekeyDetail?[address] = ledgerDetail
        } else {
            self.rekeyDetail = [address: ledgerDetail]
        }
    }
}

extension AccountInformation {
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case name = "name"
        case type = "type"
        case ledgerDetail = "ledgerDetail"
        case receivesNotification = "receivesNotification"
        case rekeyDetail = "rekeyDetail"
    }
}

extension AccountInformation: Encodable { }

extension AccountInformation: Equatable {
    static func == (lhs: AccountInformation, rhs: AccountInformation) -> Bool {
        return lhs.address == rhs.address
    }
}

enum AccountType: String, Model {
    case standard = "standard"
    case watch = "watch"
    case ledger = "ledger"
    case multiSig = "multiSig"
    case rekeyed = "rekeyed"
}

extension AccountType: Encodable { }
