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

//   SwapDividerView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SwapDividerView:
    View,
    ViewModelBindable {
    private lazy var switchControl = SegmentedControl()
    private lazy var setAmountControl = SegmentedControl(distributionMode: .fillProportionally)

    func customize(_ theme: SwapDividerViewTheme) {
        addSeparator(theme)
        addSwitch(theme)
        addSetAmount(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: SwapDividerViewModel?) {
        setAmountControl.removeAllSegments()

        guard let viewModel = viewModel else {
            return
        }

        if let title = viewModel.amountAdjustTitle {
            setAmountControl.add(
                segment: AmountAdjustSegment(title: title)
            )
        } else {
            setAmountControl.add(
                segment: AmountAdjustSegment()
            )
        }

        setAmountControl.add(
            segment: MaxSegment()
        )
    }
}

extension SwapDividerView {
    private func addSeparator(_ theme: SwapDividerViewTheme) {
        addSeparator(theme.horizontalSeparator)
    }

    private func addSwitch(_ theme: SwapDividerViewTheme) {
        switchControl.backgroundImage = theme.backgroundImage
        switchControl.add(segment: SwitchSegment())

        addSubview(switchControl)
        switchControl.snp.makeConstraints {
            $0.leading == theme.horizontalPadding
            $0.top.bottom == 0
        }
    }

    private func addSetAmount(_ theme: SwapDividerViewTheme) {
        setAmountControl.separatorImage = theme.verticalSeparatorImage
        setAmountControl.backgroundImage = theme.backgroundImage

        var amountAdjustSegment = AmountAdjustSegment()
        amountAdjustSegment.configureForDisabledState()
        var maxSegment = MaxSegment()
        maxSegment.configureForDisabledState()
        setAmountControl.add(segments: [
            amountAdjustSegment,
            maxSegment
        ])

        addSubview(setAmountControl)
        setAmountControl.snp.makeConstraints {
            $0.leading >= switchControl.snp.trailing
            $0.trailing == theme.horizontalPadding
            $0.top.bottom == 0
        }
    }
}
