// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CardsFundAddressesList.swift

import Foundation
import MagpieCore
import MacaroonUtils

public final class CardsFundAddressesList: ALGEntityModel {
    public let results: [CardsFundAddressesListResult]

    public init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.results = apiModel.results
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.results = results
        return apiModel
    }
}

extension CardsFundAddressesList {
    public struct APIModel: ALGAPIModel {
        var results: [CardsFundAddressesListResult]

        public init() {
            self.results = []
        }
    }
}


public struct CardsFundAddressesListResult: Codable {
    public let ownerAddress: String
    public let cardFundAddress: String?
    public let nftRewardState: String?
    
    public init(ownerAddress: String, cardFundAddress: String?, nftRewardState: String?) {
        self.ownerAddress = ownerAddress
        self.cardFundAddress = cardFundAddress
        self.nftRewardState = nftRewardState
    }
    
    private enum CodingKeys: String, CodingKey {
        case ownerAddress = "owner_address"
        case cardFundAddress = "card_fund_address"
        case nftRewardState = "nft_reward_state"
    }
}
