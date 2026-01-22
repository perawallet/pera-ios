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

//   TransactionItem.swift

public protocol TransactionItem {
    var id: String? { get }
    var date: Date? { get }
    var type: TransactionType? { get }
    var sender: String? { get }
    var receiver: String? { get }
    var contact: Contact? { get set }
    var isSelfTransaction: Bool { get }
    var appId: Int64? { get }
    var status: TransactionStatus? { get set }
    var allInnerTransactionsCount: Int { get }
    var noteRepresentation: String? { get }
    
    func isPending() -> Bool
    func isAssetAdditionTransaction(for address: String) -> Bool
}

extension TransactionItem {
    public var date: Date? {
        return nil
    }
    
}

public enum TransactionStatus: String {
    case pending = "PENDING"
    case completed = "COMPLETED"
    case failed = "FAILED"
    
    public init?(fromString string: String) {
        self.init(rawValue: string.uppercased())
    }
    
    public static func == (lhs: TransactionStatus, rhs: TransactionStatus) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
