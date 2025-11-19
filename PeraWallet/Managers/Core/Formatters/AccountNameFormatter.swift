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

//   AccountNameFormatter.swift

import pera_wallet_core

enum AccountNameFormatter {
    
    static func accountTitles(localAccount: AccountInformation, accountType: PeraAccount.AccountType, authorizedAccountType: PeraAccount.AuthorizedAccountType?) -> PeraAccount.Titles {
        
        let primaryTitle: String
        
        if localAccount.name.isEmpty {
            primaryTitle = localAccount.address.shortAddressDisplay
        } else {
            primaryTitle = localAccount.name
        }
        
        guard let authorizedAccountType else {
            let secondaryTitle = nonRekeyedAccountSecondaryTitle(accountType: accountType, primaryTitle: primaryTitle, truncatedAddress: localAccount.address.shortAddressDisplay)
            return PeraAccount.Titles(primary: primaryTitle, secondary: secondaryTitle)
        }
        
        return PeraAccount.Titles(primary: primaryTitle, secondary: authorizedAccountType.name)
    }
    
    private static func nonRekeyedAccountSecondaryTitle(accountType: PeraAccount.AccountType, primaryTitle: String, truncatedAddress: String) -> String? {
        guard primaryTitle != truncatedAddress else {
            return accountType.isStandardAccount ? nil : accountType.name
        }
        return truncatedAddress
    }
}
