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

//   WarningCheckView.swift

import MacaroonUIKit
import UIKit

final class WarningCheckView:
    View,
    ViewModelBindable,
    ListReusable {
    
    // MARK: - Properties
    
    private lazy var titleView = UILabel()
    private lazy var mainCurrencyView = UILabel()
    private lazy var secondaryCurrencyView = UILabel()
    
    // MARK: - Setups

    func customize(
        _ theme: WarningCheckViewTheme
    ) {
        addTitle(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ title: String?
    ) {
        titleView.text = title
    }
    
    private func addTitle(
        _ theme: WarningCheckViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }
    }
}
