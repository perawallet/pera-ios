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

//
//   WCAlgosTransactionViewTheme.swift

import Foundation
import MacaroonUIKit

extension WCAlgosTransactionView {
    struct Theme: LayoutSheet, StyleSheet {
        let rawTransactionButtonStyle: ButtonStyle
        let buttonEdgeInsets: LayoutPaddings
        let buttonsCorner: Corner
        let accountInformationTheme: TitledTransactionAccountNameViewTheme
        let textInformationTheme: TransactionTextInformationViewTheme
        let amountInformationTheme: TransactionAmountInformationViewTheme
        let assetInformationTheme: WCAssetInformationViewTheme

        init(_ family: LayoutFamily) {
            self.rawTransactionButtonStyle = [
                .title("wallet-connect-raw-transaction-title".localized),
                .titleColor([.normal(AppColors.Components.Button.Secondary.text)]),
                .font(Fonts.DMSans.medium.make(13)),
                .backgroundColor(AppColors.Components.Button.Secondary.background)
            ]
            self.buttonsCorner = Corner(radius: 18)
            self.buttonEdgeInsets = (8, 12, 8, 12)
            self.accountInformationTheme = TitledTransactionAccountNameViewTheme()
            self.textInformationTheme = TransactionTextInformationViewTheme()
            self.amountInformationTheme = TransactionAmountInformationViewTheme()
            self.assetInformationTheme = WCAssetInformationViewTheme()
        }
    }
}
