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
//   AlgoStatisticsValueChangeViewModel.swift

import UIKit
import MacaroonUIKit

final class AlgoStatisticsValueChangeViewModel: PairedViewModel {
    private(set) var image: UIImage?
    private(set) var valueColor: UIColor?
    private(set) var value: String?

    init(_ model: AlgoUSDPriceChange) {
        bindImage(model)
        bindValueColor(model)
        bindValue(model)
    }
}

extension AlgoStatisticsValueChangeViewModel {
    private func bindImage(_ priceChange: AlgoUSDPriceChange) {
        switch priceChange.getValueChangeStatus() {
        case .increased:
            image = img("icon-arrow-up-green")
        case .decreased:
            image = img("icon-arrow-down-red")
        case .stable:
            image = nil
        }
    }

    private func bindValueColor(_ priceChange: AlgoUSDPriceChange) {
        switch priceChange.getValueChangeStatus() {
        case .increased:
            valueColor = AppColors.Shared.Helpers.positive.uiColor
        case .decreased:
            valueColor = AppColors.Shared.Helpers.negative.uiColor
        case .stable:
            valueColor = nil
        }
    }

    private func bindValue(_ priceChange: AlgoUSDPriceChange) {
        switch priceChange.getValueChangeStatus() {
        case .increased:
            value = (priceChange.getValueChangePercentage() - 1).toPercentage
        case .decreased:
            value = (1 - priceChange.getValueChangePercentage()).toPercentage
        case .stable:
            value = nil
        }
    }
}
