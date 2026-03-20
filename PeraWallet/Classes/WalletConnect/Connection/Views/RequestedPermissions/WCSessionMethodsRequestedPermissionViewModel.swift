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

//   WCSessionMethodsRequestedPermissionViewModel.swift

import Foundation
import MacaroonUIKit
import pera_wallet_core

struct WCSessionRequestedPermissionViewModel: ViewModel {
    let title: TextProvider
    let rows: [TextProvider]
    
    init(methods: Set<WCSessionSupportedMethod>, events: Set<WCSessionSupportedEvent>) {
        title =
            String(localized: "wc-session-connection-requested-permissions")
                .captionMedium(
                    alignment: .natural,
                    lineBreakMode: .byTruncatingTail
                )
        
        let methodRows = methods.compactMap {
            WalletConnectMethod(rawValue: $0.rawValue)?.title.bodyRegular(lineBreakMode: .byTruncatingTail)
        }
        let eventRows = events.compactMap {
            WalletConnectEvent(rawValue: $0.rawValue)?.title.bodyRegular(lineBreakMode: .byTruncatingTail)
        }

        rows = methodRows + eventRows
    }
}
