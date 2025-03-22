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

//   SelectAddressListItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SelectAddressListItemView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var titleView = UILabel()
    private lazy var mainCurrencyView = UILabel()
    private lazy var secondaryCurrencyView = UILabel()

    func customize(
        _ theme: SelectAddressListItemTheme
    ) {
        addTitle(theme)
        addMainCurrency(theme)
        addSecondaryCurrency(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: SelectAddressListItemViewModel?
    ) {
        titleView.text = viewModel?.title?.string
        mainCurrencyView.text = viewModel?.mainCurrency?.string
        secondaryCurrencyView.text = viewModel?.secondaryCurrency?.string
    }
}

extension SelectAddressListItemView {

    private func addTitle(
        _ theme: SelectAddressListItemTheme
    ) {
        titleView.customizeAppearance(theme.titleTheme.title)

        addSubview(titleView)
        
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }
    }

    private func addMainCurrency(
        _ theme: SelectAddressListItemTheme
    ) {
        mainCurrencyView.customizeAppearance(theme.currencyTheme.main)

        addSubview(mainCurrencyView)
        mainCurrencyView.snp.makeConstraints {
            $0.top == 0
            $0.trailing == 0
        }
    }
    
    private func addSecondaryCurrency(
        _ theme: SelectAddressListItemTheme
    ) {
        secondaryCurrencyView.customizeAppearance(theme.currencyTheme.secondary)

        addSubview(secondaryCurrencyView)
        secondaryCurrencyView.snp.makeConstraints {
            $0.top == mainCurrencyView.snp.bottom
            $0.bottom == 0
            $0.trailing == 0
        }
    }

}
