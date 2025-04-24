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

//   AlogranSecureBackupImportMnemonicTheme.swift

import Foundation
import MacaroonUIKit

struct AlogranSecureBackupImportMnemonicTheme: AccountRecoverViewTheme {
    let title: TextStyle

    let horizontalStackViewTopInset: LayoutMetric
    let horizontalStackViewSpacing: LayoutMetric
    let horizontalInset: LayoutMetric
    let topInset: LayoutMetric
    let bottomInset: LayoutMetric
    let verticalStackViewSpacing: LayoutMetric
    let firstColumnCount: Int
    let secondColumnCount: Int
    
    init(_ family: LayoutFamily) {
        self.title = [
            .textAlignment(.left),
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Typography.titleMedium()),
            .text(String(localized: "algorand-secure-backup-import-recover-mnemonic-title"))
        ]

        self.horizontalStackViewTopInset = 37
        self.horizontalInset = 24
        self.topInset = 2
        self.bottomInset = 100
        self.horizontalStackViewSpacing = 8
        self.verticalStackViewSpacing = 12
        self.firstColumnCount = 6
        self.secondColumnCount = 6
    }
}
