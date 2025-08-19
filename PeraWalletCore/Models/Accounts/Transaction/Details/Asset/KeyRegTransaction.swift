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

//   KeyRegTransaction.swift

import Foundation

public struct KeyRegTransaction: ALGAPIModel {
    public let voteParticipationKey: String?
    public let selectionParticipationKey: String?
    public let stateProofKey: String?
    public let voteFirstValid: UInt64?
    public let voteLastValid: UInt64?
    public let voteKeyDilution: UInt64?
    public let nonParticipation: Bool

    public init() {
        self.voteParticipationKey = nil
        self.selectionParticipationKey = nil
        self.stateProofKey = nil
        self.voteFirstValid = nil
        self.voteLastValid = nil
        self.voteKeyDilution = nil
        self.nonParticipation = false
    }
}

extension KeyRegTransaction {
    public var isOnlineKeyRegTransaction: Bool {
        guard
            let voteParticipationKey,
            let selectionParticipationKey,
            voteKeyDilution != nil,
            voteFirstValid != nil,
            voteLastValid != nil
        else {
            return false
        }

        return !voteParticipationKey.isEmptyOrBlank && !selectionParticipationKey.isEmptyOrBlank
    }
}

extension KeyRegTransaction {
    private enum CodingKeys:
        String,
        CodingKey {
        case voteParticipationKey = "vote-participation-key"
        case selectionParticipationKey = "selection-participation-key"
        case stateProofKey = "state-proof-key"
        case voteFirstValid = "vote-first-valid"
        case voteLastValid = "vote-last-valid"
        case voteKeyDilution = "vote-key-dilution"
        case nonParticipation = "non-participation"
    }
}
