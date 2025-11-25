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

//   AccountIconProvider.swift

import SwiftUI

final class AccountIconProvider {
    
    static func iconData(account: PeraAccount) -> ImageType.IconData {
        ImageType.IconData(image: image(account: account), tintColor: tintColor(account: account), backgroundColor: backgroundColor(account: account))
    }
    
    private static func image(account: PeraAccount) -> ImageResource {
        
        guard account.authType == nil else { return .Icons.rekeyedAccount }
        
        return switch account.type {
        case .algo25:
                .Icons.wallet
        case .universalWallet:
                .Icons.walletUniversal
        case .watch:
                .Icons.watchAccount
        case .ledger:
                .Icons.ledger
        case .joint:
                .Icons.group
        case .invalid:
                .Icons.rekeyedAccount
        }
    }
    
    private static func tintColor(account: PeraAccount) -> Color {
        if account.type == .invalid || account.authType == .invalid { return .Helpers.negative }
        if account.type == .watch { return .Wallet.wallet1Icon }
        if account.type == .joint { return .Wallet.wallet1 }
        if account.type == .ledger || account.authType == .ledger { return .Wallet.wallet3Icon }
        return .Wallet.wallet4Icon
    }
    
    private static func backgroundColor(account: PeraAccount) -> Color {
        if account.type == .invalid || account.authType == .invalid { return .Helpers.negativeLighter }
        if account.type == .watch { return .Wallet.wallet1 }
        if account.type == .joint { return .Wallet.wallet1Icon }
        if account.type == .ledger || account.authType == .ledger { return .Wallet.wallet3 }
        return .Wallet.wallet4
    }
}
