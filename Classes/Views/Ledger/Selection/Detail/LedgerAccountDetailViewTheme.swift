// Copyright 2019 Algorand, Inc.

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
//   LedgerAccountDetailViewTheme.swift

import Macaroon
import CoreGraphics

struct LedgerAccountDetailViewTheme: LayoutSheet, StyleSheet {
    let ledgerAccountTitle: TextStyle
    let assetsTitle: TextStyle
    let signedByTitle: TextStyle

    let horizontalPadding: CGFloat = 24
    let topPadding: CGFloat = 40
    let titleTopPadding: CGFloat = 32
    let stackViewTopPadding: CGFloat = 4

    init(_ family: LayoutFamily) {
        self.ledgerAccountTitle = [
            .textAlignment(.left),
            .textOverflow(.fitting),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Components.Text.main),
            .content("ledger-account-detail-title".localized)
        ]
        self.assetsTitle = [
            .textAlignment(.left),
            .textOverflow(.fitting),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Components.Text.main),
            .content("ledger-account-details-assets".localized)
        ]
        self.signedByTitle = [
            .textAlignment(.left),
            .textOverflow(.fitting),
            .font(Fonts.DMSans.medium.make(15)),
            .textColor(AppColors.Components.Text.main)
        ]
    }
}
