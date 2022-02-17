// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   MuteNotificationsListActionViewModel.swift

import Foundation
import MacaroonUIKit

struct MuteNotificationsListActionViewModel:
    ListActionViewModel,
    BindableViewModel {
    let subtitle: EditText?
    
    private(set) var title: EditText?
    private(set) var icon: Image?
    
    init<T>(
        _ model: T
    ) {
        subtitle = nil
        
        bind(model)
    }
    
    mutating func bind<T>(
        _ model: T
    ) {
        if let account = model as? Account {
            bindIcon(account)
            bindTitle(account)
            return
        }
    }
}

extension MuteNotificationsListActionViewModel {
    mutating func bindIcon(
        _ account: Account
    ) {
        icon = account.receivesNotification
            ? "icon-options-mute-notification"
            : "icon-options-unmute-notification"
    }
    
    mutating func bindTitle(
        _ account: Account
    ) {
        title = account.receivesNotification
            ? Self.getTitle("options-mute-notification".localized)
            : Self.getTitle("options-unmute-notification".localized)
    }
}
