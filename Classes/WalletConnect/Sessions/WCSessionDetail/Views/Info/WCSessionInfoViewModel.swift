// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCSessionInfoViewModel.swift

import Foundation
import MacaroonUIKit

struct WCSessionInfoViewModel: ViewModel {
    private(set) var connectionDate: WCSessionConnectionDateSecondaryListItemViewModel?
    private(set) var expirationDate: WCSessionExpirationDateSecondaryListItemViewModel?
    private(set) var sessionStatus: WCSessionStatusSecondaryListItemViewModel?

    init(_ draft: WCSessionDraft) {
        bindConnectionDate(draft)

        if let wcV2Session = draft.wcV2Session {
            bindExpirationDate(wcV2Session)
            bindSessionStatus(.idle)
            return
        }
    }
}

extension WCSessionInfoViewModel {
    private mutating func bindConnectionDate(_ draft: WCSessionDraft) {
        connectionDate = WCSessionConnectionDateSecondaryListItemViewModel(draft)
    }
}

extension WCSessionInfoViewModel {
    private mutating func bindExpirationDate(_ wcV2Session: WalletConnectV2Session) {
        expirationDate = WCSessionExpirationDateSecondaryListItemViewModel(wcV2Session)
    }

    mutating func bindSessionStatus(_ status: WCSessionStatus) {
        sessionStatus = WCSessionStatusSecondaryListItemViewModel(status)
    }
}
