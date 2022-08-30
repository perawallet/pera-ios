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

//   AssetAmountInputView.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class AssetAmountInputView: View {
    private lazy var iconView = URLImageView()
    private lazy var amountInputView = TextField()
    private lazy var detailView = UILabel()

    func customize(
        _ theme: AssetAmountInputViewTheme
    ) {
        addIcon(theme)
        addAmountInput(theme)
        addDetail(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: AssetAmountInputViewModel?
    ) {
        guard let viewModel = viewModel else {
            return
        }

        iconView.load(from: viewModel.imageSource)

        if let inputValue = viewModel.inputValue {
            inputValue.load(in: amountInputView)
        }

        amountInputView.isUserInteractionEnabled = viewModel.isInputEditable

        if let detail = viewModel.detail {
            detail.load(in: detailView)
        } else {
            detailView.clearText()
        }
    }
}

extension AssetAmountInputView {
    private func addIcon(
        _ theme: AssetAmountInputViewTheme
    ) {
        iconView.customizeAppearance(theme.icon)
        
        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.centerY == 0
            $0.leading == 0
        }
    }

    private func addAmountInput(
        _ theme: AssetAmountInputViewTheme
    ) {
        amountInputView.customizeAppearance(theme.amountInput)
        
        addSubview(amountInputView)
        amountInputView.fitToIntrinsicSize()
        amountInputView.snp.makeConstraints {
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.contentHorizontalOffset
            $0.trailing <= 0
        }
    }

    private func addDetail(
        _ theme: AssetAmountInputViewTheme
    ) {
        detailView.customizeAppearance(theme.detail)

        addSubview(detailView)
        detailView.fitToIntrinsicSize()
        detailView.snp.makeConstraints {
            $0.top == amountInputView.snp.bottom
            $0.bottom == 0
            $0.trailing <= 0
        }
    }
}
