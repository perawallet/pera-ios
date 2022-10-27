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

//   SwapAssetAmountView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class SwapAssetAmountView:
    View,
    AssetAmountInputViewDelegate,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .didSelectAsset: GestureInteraction()
    ]
    
    weak var delegate: SwapAssetAmountViewDelegate?

    var currentAmount: String? {
        return amountInputView.currentAmount
    }

    private lazy var leftTitleView = Label()
    private lazy var rightTitleView = Label()
    private lazy var amountInputView = AssetAmountInputView()
    private lazy var assetSelectionView = SwapAssetSelectionView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
    }

    func customize(
        _ theme: SwapAssetAmountViewTheme
    ) {
        addLeftTitle(theme)
        addRightTitle(theme)
        addAssetSelection(theme)
        addAmountInput(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func setListeners() {
        amountInputView.delegate = self
    }

    func bindData(
        _ viewModel: SwapAssetAmountViewModel?
    ) {
        guard let viewModel = viewModel else {
            return
        }

        if let leftTitle = viewModel.leftTitle {
            leftTitle.load(in: leftTitleView)
        } else {
            leftTitleView.clearText()
        }

        if let rightTitle = viewModel.rightTitle {
            rightTitle.load(in: rightTitleView)
        } else {
            rightTitleView.clearText()
        }

        amountInputView.bindData(viewModel.assetAmountValue)
        assetSelectionView.bindData(viewModel.assetSelectionValue)
    }

    func beginEditing() {
        amountInputView.beginEditing()
    }

    func endEditing() {
        amountInputView.endEditing()
    }

    func updateInput(
        _ input: String?
    ) {
        amountInputView.updateInput(input)
    }
}

extension SwapAssetAmountView {
    private func addLeftTitle(
        _ theme: SwapAssetAmountViewTheme
    ) {
        leftTitleView.customizeAppearance(theme.leftTitle)

        addSubview(leftTitleView)
        leftTitleView.fitToIntrinsicSize()
        leftTitleView.contentEdgeInsets.bottom = theme.spacingBetweenLeftTitleAndAmountInput
        leftTitleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addRightTitle(
        _ theme: SwapAssetAmountViewTheme
    ) {
        rightTitleView.customizeAppearance(theme.rightTitle)

        addSubview(rightTitleView)
        rightTitleView.fitToIntrinsicSize()
        rightTitleView.contentEdgeInsets.bottom = theme.spacingBetweenRightTitleAndAssetSelection
        rightTitleView.snp.makeConstraints {
            $0.top == 0
            $0.leading >= leftTitleView.snp.trailing + theme.minimumSpacingBetweenTitles
            $0.trailing == 0
        }
    }

    private func addAssetSelection(
        _ theme: SwapAssetAmountViewTheme
    ) {
        assetSelectionView.customize(theme.assetSelection)

        addSubview(assetSelectionView)
        assetSelectionView.fitToHorizontalIntrinsicSize()
        assetSelectionView.fitToVerticalIntrinsicSize(
             hugging: .defaultLow,
             compression: .required
        )
        assetSelectionView.snp.makeConstraints {
            $0.top == rightTitleView.snp.bottom
            $0.trailing == 0
            $0.bottom <= 0
        }

        startPublishing(
            event: .didSelectAsset,
            for: assetSelectionView
        )
    }

    private func addAmountInput(
        _ theme: SwapAssetAmountViewTheme
    ) {
        amountInputView.customize(theme.assetAmountInput)

        addSubview(amountInputView)
        amountInputView.fitToHorizontalIntrinsicSize()
        amountInputView.fitToVerticalIntrinsicSize(
             hugging: .defaultLow,
             compression: .required
         )
        amountInputView.snp.makeConstraints {
            $0.top == leftTitleView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= assetSelectionView.snp.leading - theme.minimumSpacingBetweenInputAndSelection
        }
    }
}

extension SwapAssetAmountView {
    func assetAmountInputView(
        _ assetAmountInputView: AssetAmountInputView,
        didChangeTextIn textField: TextField
    ) {
        delegate?.swapAssetAmountView(
            self,
            didChangeTextIn: textField
        )
    }

    func assetAmountInputView(
        _ assetAmountInputView: AssetAmountInputView,
        didBeginEditingIn textField: TextField
    ) {
        delegate?.swapAssetAmountView(
            self,
            didBeginEditingIn: textField
        )
    }

    func assetAmountInputView(
        _ assetAmountInputView: AssetAmountInputView,
        didEndEditingIn textField: TextField
    ) {
        delegate?.swapAssetAmountView(
            self,
            didEndEditingIn: textField
        )
    }

    func assetAmountInputView(
        _ assetAmountInputView: AssetAmountInputView,
        shouldChangeCharactersIn textField: TextField,
        with range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.swapAssetAmountView(
            self,
            shouldChangeCharactersIn: textField,
            with: range,
            replacementString: string
        )
    }
}

extension SwapAssetAmountView {
    enum Event {
        case didSelectAsset
    }
}

protocol SwapAssetAmountViewDelegate: AnyObject {
    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        didChangeTextIn textField: TextField
    )
    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        didBeginEditingIn textField: TextField
    )
    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        didEndEditingIn textField: TextField
    )
    func swapAssetAmountView(
        _ swapAssetAmountView: SwapAssetAmountView,
        shouldChangeCharactersIn textField: TextField,
        with range: NSRange,
        replacementString string: String
    ) -> Bool
}
