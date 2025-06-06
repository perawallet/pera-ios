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

//
//   PortfolioCalculationInfoViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct PortfolioCalculationInfoViewTheme:
    StyleSheet,
    LayoutSheet {
    var title: TextStyle
    var body: TextStyle
    var spacingBetweenTitleAndBody: LayoutMetric
    
    init(
        _ family: LayoutFamily
    ) {
        self.title = [
            .text(Self.getTitle()),
            .textColor(Colors.Text.main),
            .textOverflow(FittingText())
        ]
        self.body = [
            .text(Self.getBody()),
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText())
        ]
        self.spacingBetweenTitleAndBody = 20
    }
}

extension PortfolioCalculationInfoViewTheme {
    private static func getTitle() -> EditText {        
        return .attributedString(
            String(localized: "portfolio-calculation-title")
                .bodyLargeMedium()
        )
    }
    
    private static func getBody() -> EditText {
        return .attributedString(
            String(localized: "portfolio-calculation-description")
                .bodyRegular()
        )
    }
}
