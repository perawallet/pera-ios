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
//   WCTransactionErrorResponse.swift

import Foundation

enum WCTransactionErrorResponse: Error {
    case rejected(Rejection)
    case unauthorized(Authorization)
    case unsupported(Support)
    case invalidInput(Invalid)

    /// <mark>: WC v2
    case unauthorizedChain(String)
    case unauthorizedMethod(String)
    case unsupportedNamespace
    case unsupportedChains
    case unsupportedMethods
    case noSessionForTopic
    case userRejectedChains(
        requestedNetwork: String,
        expectedNetwork: String
    )
    case generic(Error)

    var message: String {
        switch self {
        case let .rejected(type):
            switch type {
            case .user:
                return String(localized: "wallet-connect-request-error-rejected-user")
            case .failedValidation:
                return String(localized: "wallet-connect-transaction-error-group-validation")
            case .unsignable:
                return String(localized: "wallet-connect-transaction-error-group-unauthorized-user")
            case .alreadyDisplayed:
                return String(localized: "wallet-connect-request-error-already-displayed")
            case .none:
                return String(localized: "wallet-connect-transaction-error-rejected")
            }
        case let .unauthorized(type):
            switch type {
            case .nodeMismatch:
                return String(localized: "wallet-connect-transaction-error-node")
            case .dataSignerNotFound:
                return String(localized: "wallet-connect-data-error-invalid-signer")
            case .transactionSignerNotFound:
                return String(localized: "wallet-connect-transaction-error-invalid-signer")
            case .none:
                return String(localized: "wallet-connect-transaction-error-unauthorized")
            }
        case let .unsupported(type):
            switch type {
            case .unknownTransaction:
                return String(localized: "wallet-connect-transaction-error-unsupported-type")
            case .multisig:
                return String(localized: "wallet-connect-transaction-error-multisig")
            case .none:
                return String(localized: "wallet-connect-transaction-error-unsupported")
            }
        case let .invalidInput(type):
            switch type {
            case .dataCount:
                return String(localized: "wallet-connect-data-error-data-size")
            case .transactionCount:
                return String(localized: "wallet-connect-transaction-error-transaction-size")
            case .dataParse:
                return String(localized: "wallet-connect-data-error-parse")
            case .transactionParse:
                return String(localized: "wallet-connect-transaction-error-parse")
            case .publicKey:
                return String(localized: "wallet-connect-transaction-error-invalid-key")
            case .asset:
                return String(localized: "wallet-connect-transaction-error-invalid-asset")
            case .unableToFetchAsset:
                return String(localized: "wallet-connect-transaction-error-unable-fetch-asset")
            case .unsignable:
                return String(localized: "wallet-connect-transaction-error-unable-sign")
            case .group:
                return String(localized: "wallet-connect-transaction-error-group")
            case .signer:
                return String(localized: "wallet-connect-transaction-error-account-not-exist")
            case .session:
                return String(localized: "wallet-connect-transaction-error-session-not-found")
            case .none:
                return String(localized: "wallet-connect-transaction-error-invalid")
            }
        case .unauthorizedChain(let chain):
            return String(format: String(localized: "wallet-connect-v2-unauthorized-chain-error-message"), chain)
        case .unauthorizedMethod(let method):
            return String(format: String(localized: "wallet-connect-v2-unauthorized-method-error-message"), method)
        case .unsupportedNamespace:
            return String(localized: "wallet-connect-unsupported-namespace-error-message")
        case .unsupportedChains:
            return String(localized: "wallet-connect-unsupported-chains-error-message")
        case .unsupportedMethods:
            return String(localized: "wallet-connect-unsupported-methods-error-message")
        case .noSessionForTopic:
            return String(localized: "wallet-connect-no-session-for-topic-error-message")
        case .userRejectedChains(let requestedNetwork, let expectedNetwork):
            return String(format: String(localized: "wallet-connect-v2-user-rejected-chains-error-message"), requestedNetwork, expectedNetwork)
        case .generic(let error):
            return error.localizedDescription
        }
    }
}

extension WCTransactionErrorResponse: RawRepresentable {
    typealias RawValue = Int

    init?(rawValue: RawValue) {
        switch rawValue {
        case 4001:
            self = .rejected(.none)
        case 4100:
            self = .unauthorized(.none)
        case 4200:
            self = .unsupported(.none)
        case 4300:
            self = .invalidInput(.none)
        default:
            return nil
        }
    }

    var rawValue: RawValue {
        switch self {
        case .rejected:
            return 4001
        case .unauthorized:
            return 4100
        case .unsupported:
            return 4200
        case .invalidInput:
            return 4300
        case .noSessionForTopic:
            return 7001
        case .unauthorizedChain:
            return 3005
        case .unauthorizedMethod:
            return 3001
        case .unsupportedNamespace:
            return 5104
        case .unsupportedChains:
            return 5100
        case .unsupportedMethods:
            return 5101
        case .userRejectedChains:
            return 5001
        case .generic:
            return 9999
        }
    }
}

extension WCTransactionErrorResponse {
    enum Rejection {
        case user
        case failedValidation
        case unsignable
        case alreadyDisplayed
        case none
    }

    enum Authorization {
        case nodeMismatch
        case dataSignerNotFound
        case transactionSignerNotFound
        case none
    }

    enum Support {
        case unknownTransaction
        case multisig
        case none
    }

    enum Invalid {
        case dataCount
        case transactionCount
        case dataParse
        case transactionParse
        case publicKey
        case asset
        case unableToFetchAsset
        case unsignable
        case group
        case signer
        case session
        case none
    }
}
