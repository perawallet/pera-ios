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

//   ConfirmSwapScreen.swift

import MacaroonUIKit
import UIKit

final class ConfirmSwapScreen: BaseScrollViewController {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var userAssetView = SwapAssetAmountView()
    private lazy var toSeparatorView = TitleSeparatorView()
    private lazy var poolAssetView = SwapAssetAmountView()
    private lazy var priceInfoView = SwapInfoActionItemView()
    private lazy var slippageInfoView = SwapInfoActionItemView()
    private lazy var priceImpactInfoView = SwapInfoItemView()
    private lazy var minimumReceivedInfoView = SwapInfoItemView()
    private lazy var exchangeFeeInfoView = SwapInfoItemView()
    private lazy var peraFeeInfoView = SwapInfoItemView()
    private lazy var confirmActionView: LoadingButton = {
        let loadingIndicator = ViewLoadingIndicator()
        loadingIndicator.applyStyle(theme.confirmActionIndicator)
        return LoadingButton(loadingIndicator: loadingIndicator)
    }()

    private let currencyFormatter: CurrencyFormatter
    private let dataController: ConfirmSwapDataController
    private let theme: ConfirmSwapScreenTheme

    init(
        dataController: ConfirmSwapDataController,
        theme: ConfirmSwapScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.currencyFormatter = CurrencyFormatter()
        self.dataController = dataController
        self.theme = theme
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        title = "swap-confirm-title".localized
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeAppearance(theme.background)
    }

    override func setListeners() {
        super.setListeners()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .willUpdateSlippage: break
            case .didUpdateSlippage(let quote):
                self.confirmActionView.stopLoading()
            case .didFailToUpdateSlippage(let error):
                self.confirmActionView.stopLoading()
            case .willPrepareTransactions: break
            case .didPrepareTransactions(let swapTransactionPreparation):
                self.confirmActionView.stopLoading()
                self.eventHandler?(.didTapConfirm(swapTransactionPreparation))
            case .didFailToPrepareTransactions(let error):
                self.confirmActionView.stopLoading()
            }
        }
    }

    override func prepareLayout() {
        super.prepareLayout()
        addUserAsset()
        addToSeparator()
        addPoolAsset()
        addPriceInfo()
        addSlippageInfo()
        addPriceImpactInfo()
        addMinimumReceivedInfo()
        addExchangeFeeInfo()
        addPeraFeeInfo()
        addConfirmAction()
    }

    override func bindData() {
        super.bindData()
        bindData(dataController.quote)
    }
}

extension ConfirmSwapScreen {
	private func addUserAsset() {
        userAssetView.customize(theme.userAsset)

        contentView.addSubview(userAssetView)
        userAssetView.fitToIntrinsicSize()
        userAssetView.snp.makeConstraints {
            $0.top == theme.userAssetTopInset
            $0.leading == theme.assetHorizontalInset
            $0.trailing == theme.assetHorizontalInset
        }
	}

	private func addToSeparator() {
        toSeparatorView.customize(theme.toSeparator)

        contentView.addSubview(toSeparatorView)
        toSeparatorView.fitToIntrinsicSize()
        toSeparatorView.snp.makeConstraints {
            $0.top == userAssetView.snp.bottom + theme.toSeparatorTopInset
            $0.leading == 0
            $0.trailing == 0
        }
	}

	private func addPoolAsset() {
        poolAssetView.customize(theme.poolAsset)

        contentView.addSubview(poolAssetView)
        poolAssetView.fitToIntrinsicSize()
        poolAssetView.snp.makeConstraints {
            $0.top == toSeparatorView.snp.bottom + theme.poolAssetTopInset
            $0.leading == theme.assetHorizontalInset
            $0.trailing == theme.assetHorizontalInset
        }
	}

    private func addPriceInfo() {
        priceInfoView.customize(theme.infoActionItem)

        let topSeparator = contentView.attachSeparator(
            theme.assetSeparator,
            to: poolAssetView,
            margin: theme.assetSeparatorPadding
        )

        contentView.addSubview(priceInfoView)
        priceInfoView.fitToIntrinsicSize()
        priceInfoView.snp.makeConstraints {
            $0.top == topSeparator.snp.bottom + theme.infoSectionPaddings.top
            $0.leading == theme.infoSectionPaddings.leading
            $0.trailing == theme.infoSectionPaddings.trailing
        }

        priceInfoView.startObserving(event: .didTapAction) {
            [weak self] in
            guard let self = self else { return }

        }
    }

    private func addSlippageInfo() {
        slippageInfoView.customize(theme.infoActionItem)

        contentView.addSubview(slippageInfoView)
        slippageInfoView.fitToIntrinsicSize()
        slippageInfoView.snp.makeConstraints {
            $0.top == priceInfoView.snp.bottom + theme.infoSectionItemSpacing
            $0.leading == theme.infoSectionPaddings.leading
            $0.trailing == theme.infoSectionPaddings.trailing
        }

        slippageInfoView.startObserving(event: .didTapInfo) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.didTapSlippageInfo)
        }

        slippageInfoView.startObserving(event: .didTapAction) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.didTapSlippageAction)
        }
    }

    private func addPriceImpactInfo() {
        priceImpactInfoView.customize(theme.infoItem)

        contentView.addSubview(priceImpactInfoView)
        priceImpactInfoView.fitToIntrinsicSize()
        priceImpactInfoView.snp.makeConstraints {
            $0.top == slippageInfoView.snp.bottom + theme.infoSectionItemSpacing
            $0.leading == theme.infoSectionPaddings.leading
            $0.trailing == theme.infoSectionPaddings.trailing
        }

        priceImpactInfoView.startObserving(event: .didTapInfo) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.didTapPriceImpactInfo)
        }
    }

    private func addMinimumReceivedInfo() {
        minimumReceivedInfoView.customize(theme.infoItem)

        contentView.addSubview(minimumReceivedInfoView)
        minimumReceivedInfoView.fitToIntrinsicSize()
        minimumReceivedInfoView.snp.makeConstraints {
            $0.top == priceImpactInfoView.snp.bottom + theme.infoSectionItemSpacing
            $0.leading == theme.infoSectionPaddings.leading
            $0.trailing == theme.infoSectionPaddings.trailing
        }
    }

    private func addExchangeFeeInfo() {
        exchangeFeeInfoView.customize(theme.infoItem)

        contentView.addSubview(exchangeFeeInfoView)
        exchangeFeeInfoView.fitToIntrinsicSize()
        exchangeFeeInfoView.snp.makeConstraints {
            $0.top == minimumReceivedInfoView.snp.bottom + theme.infoSectionItemSpacing
            $0.leading == theme.infoSectionPaddings.leading
            $0.trailing == theme.infoSectionPaddings.trailing
        }

        exchangeFeeInfoView.startObserving(event: .didTapInfo) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.didTapExchangeFeeInfo)
        }
    }

    private func addPeraFeeInfo() {
        peraFeeInfoView.customize(theme.infoItem)

        contentView.addSubview(peraFeeInfoView)
        peraFeeInfoView.fitToIntrinsicSize()
        peraFeeInfoView.snp.makeConstraints {
            $0.top == exchangeFeeInfoView.snp.bottom + theme.infoSectionItemSpacing
            $0.leading == theme.infoSectionPaddings.leading
            $0.trailing == theme.infoSectionPaddings.trailing
        }
    }

	private func addConfirmAction() {
        confirmActionView.customizeAppearance(theme.confirmAction)

        contentView.addSubview(confirmActionView)
        confirmActionView.contentEdgeInsets = theme.confirmActionContentEdgeInsets
        confirmActionView.fitToIntrinsicSize()
        confirmActionView.snp.makeConstraints {
            $0.fitToHeight(theme.confirmActionHeight)
            $0.top >= peraFeeInfoView.snp.bottom + theme.confirmActionEdgeInsets.top
            $0.leading == theme.confirmActionEdgeInsets.leading
            $0.trailing == theme.confirmActionEdgeInsets.trailing

            let bottomInset =
                view.compactSafeAreaInsets.bottom +
                (navigationController ?? self).additionalSafeAreaInsets.bottom
                + theme.confirmActionContentEdgeInsets.bottom
            $0.bottom == bottomInset
         }

        confirmActionView.addTouch(
            target: self,
            action: #selector(confirmSwap)
        )
	}
}

extension ConfirmSwapScreen {
    func bindData(
        _ quote: SwapQuote
    ) {
        let viewModel = ConfirmSwapScreenViewModel(
            quote: quote,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        userAssetView.bindData(viewModel.userAsset)
        toSeparatorView.bindData(viewModel.toSeparator)
        poolAssetView.bindData(viewModel.poolAsset)
        priceInfoView.bindData(viewModel.priceInfo)
        slippageInfoView.bindData(viewModel.slippageInfo)
        priceImpactInfoView.bindData(viewModel.priceImpactInfo)
        minimumReceivedInfoView.bindData(viewModel.minimumReceivedInfo)
        exchangeFeeInfoView.bindData(viewModel.exchangeFeeInfo)
        peraFeeInfoView.bindData(viewModel.peraFeeInfo)
    }
}

extension ConfirmSwapScreen {
    @objc
    private func confirmSwap() {
        dataController.confirmSwap()
        confirmActionView.startLoading()
    }
}

extension ConfirmSwapScreen {
    enum Event {
        case didTapConfirm(SwapTransactionPreparation)
        case didTapSlippageInfo
        case didTapSlippageAction
        case didTapPriceImpactInfo
        case didTapExchangeFeeInfo
    }
}
