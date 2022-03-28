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

//   BuyAlgoCellView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class BuyAlgoCellView:
    View,
    UIInteractionObservable,
    UIControlInteractionPublisher,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .buyAlgo: UIControlInteraction()
    ]

    private lazy var buyAlgoButton = Button()

    func customize(
        _ theme: BuyAlgoCellViewTheme
    ) {
        addBuyAlgoButton(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    class func calculatePreferredSize(
        for theme: BuyAlgoCellViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let preferredHeight =
            theme.buyAlgoButtonHeight
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension BuyAlgoCellView {
    private func addBuyAlgoButton(
        _ theme: BuyAlgoCellViewTheme
    ) {
        buyAlgoButton.customize(theme.buyAlgoButton)
        buyAlgoButton.setTitle("moonpay-buy-button-title".localized, for: .normal)

        addSubview(buyAlgoButton)
        buyAlgoButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        startPublishing(
            event: .buyAlgo,
            for: buyAlgoButton
        )
    }
}

extension BuyAlgoCellView {
    enum Event {
        case buyAlgo
    }
}
