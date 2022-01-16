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
//   PortfolioCalculationDescriptionViewController.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class PortfolioCalculationDescriptionViewController: BaseViewController {
    private lazy var portfolioCalculationDescriptionView = PortfolioCalculationDescriptionView()

    override func configureAppearance() {
        view.backgroundColor = AppColors.Shared.System.background.uiColor
        portfolioCalculationDescriptionView.bindData(PortfolioCalculationDescriptionViewModel(hasError: false))
    }

    override func setListeners() {
        portfolioCalculationDescriptionView.handlers.didCloseScreen = { [weak self] in
            guard let self = self else {
                return
            }

            self.dismissScreen()
        }
    }

    override func prepareLayout() {
        addPortfolioCalculationDescriptionView()
    }
}

extension PortfolioCalculationDescriptionViewController {
    private func addPortfolioCalculationDescriptionView() {
        view.addSubview(portfolioCalculationDescriptionView)
        portfolioCalculationDescriptionView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension PortfolioCalculationDescriptionViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }
}
