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

//   SwapStatusUpdateDraft.swift

import Foundation
import MagpieCore

public enum SwapStatus: String {
    case pending
    case inProgress = "in_progress"
    case completed
    case failed
}

public enum SwapStatusUpdateError: String {
    case other
    case userCancelled = "user_cancelled"
    case invalidSubmission = "invalid_submission"
    case blockchainError = "blockchain_error"
}

public struct SwapStatusUpdateDraft: JSONObjectBody {
    public let swapId: String
    public let swapVersion: String
    public let status: SwapStatus
    public let submittedTransactionIds: [String]?
    public let reason: SwapStatusUpdateError?
    public let appVersion: String?
    public let countryCode: String?

    public var bodyParams: [APIBodyParam] {
        var params: [APIBodyParam] = []
        params.append(.init(.status, status.rawValue))
        
        if let submittedTransactionIds, submittedTransactionIds.isNonEmpty {
            params.append(.init(.submittedTransactionIds, submittedTransactionIds))
        }
        
        if let reason {
            params.append(.init(.reason, reason.rawValue))
        }
        
        if let appVersion {
            params.append(.init(.appVersion, appVersion))
        }
        
        params.append(.init(.platform, "ios"))
        
        if let appVersion {
            params.append(.init(.appVersion, appVersion))
        }
        
        if let countryCode {
            params.append(.init(.countryCode, countryCode))
        }
        
        params.append(.init(.swapVersion, swapVersion))

        return params
    }
    
    public init(swapId: String, swapVersion: String, status: SwapStatus, submittedTransactionIds: [String]?, reason: SwapStatusUpdateError?, appVersion: String?, countryCode: String?) {
        self.swapId = swapId
        self.swapVersion = swapVersion
        self.status = status
        self.submittedTransactionIds = submittedTransactionIds
        self.reason = reason
        self.appVersion = appVersion
        self.countryCode = countryCode
    }
}
