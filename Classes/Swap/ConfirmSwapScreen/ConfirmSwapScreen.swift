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
import MagpieExceptions
import MagpieHipo
import UIKit

final class ConfirmSwapScreen: BaseScrollViewController {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var navigationTitleView = AccountNameTitleView()
    private lazy var userAssetView = SwapAssetAmountView()
    private lazy var toSeparatorView = TitleSeparatorView()
    private lazy var poolAssetView = SwapAssetAmountView()
    private lazy var priceInfoView = SwapInfoActionItemView()
    private lazy var slippageInfoView = SwapInfoActionItemView()
    private var poolAssetBottomSeparator: UIView?
    private lazy var priceImpactInfoView = SwapInfoItemView()
    private lazy var minimumReceivedInfoView = SwapInfoItemView()
    private lazy var exchangeFeeInfoView = SwapInfoItemView()
    private lazy var peraFeeInfoView = SwapInfoItemView()
    private lazy var confirmActionView: LoadingButton = {
        let loadingIndicator = ViewLoadingIndicator()
        loadingIndicator.applyStyle(theme.confirmActionIndicator)
        return LoadingButton(loadingIndicator: loadingIndicator)
    }()

    private var viewModel: ConfirmSwapScreenViewModel?
    private var isPriceReversed = false

    private let currencyFormatter: CurrencyFormatter
    private let dataController: ConfirmSwapDataController
    private let copyToClipboardController: CopyToClipboardController
    private let theme: ConfirmSwapScreenTheme

    init(
        dataController: ConfirmSwapDataController,
        copyToClipboardController: CopyToClipboardController,
        theme: ConfirmSwapScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.currencyFormatter = CurrencyFormatter()
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController
        self.theme = theme
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addNavigationTitle()
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeAppearance(theme.background)
    }

    override func setListeners() {
        super.setListeners()
        registerDataControllerEvents()
    }

    override func prepareLayout() {
        super.prepareLayout()
        addUserAsset()
        addToSeparator()
        addConfirmAction()
        addPeraFeeInfo()
        addExchangeFeeInfo()
        addMinimumReceivedInfo()
        addPriceImpactInfo()
        addSlippageInfo()
        addPriceInfo()
        addPoolAsset()
    }

    override func bindData() {
        super.bindData()
        bindData(dataController.quote)
    }
}

extension ConfirmSwapScreen {
    private func addNavigationTitle() {
        navigationTitleView.customize(theme.navigationTitle)

        navigationItem.titleView = navigationTitleView

        let recognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(copyAccountAddress(_:))
        )
        navigationTitleView.addGestureRecognizer(recognizer)

        bindNavigationTitle()
    }

    private func bindNavigationTitle() {
        let draft = AccountNameTitleDraft(
            title: "swap-confirm-title".localized,
            account: dataController.account
        )

        let viewModel = AccountNameTitleViewModel(draft)
        navigationTitleView.bindData(viewModel)
    }
}

extension ConfirmSwapScreen {
    private func registerDataControllerEvents() {
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .willUpdateSlippage:
                self.updateUIWhenWillUpdateSlippage()
            case .didUpdateSlippage(let quote):
                self.updateUIWhenDidUpdateSlippage(quote)
            case .didFailToUpdateSlippage(let error):
                self.updateUIWhenDidFailToUpdateSlippage(error)
            case .willPrepareTransactions:
                self.updateUIWhenWillPrepareTransactions()
            case .didPrepareTransactions(let swapTransactionPreparation):
                self.updateUIWhenDidPrepareTransactions(swapTransactionPreparation)
            case .didFailToPrepareTransactions(let error):
                self.updateUIWhenDidFailToPrepareTransactions(error)
            }
        }
    }
}

extension ConfirmSwapScreen {
    private func addUserAsset() {
        userAssetView.customize(theme.userAsset)

        contentView.addSubview(userAssetView)
        userAssetView.fitToIntrinsicSize()
        userAssetView.snp.makeConstraints {
            $0.top <= theme.userAssetTopInset
            $0.top >= theme.minimumUserAssetTopInset
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

    private func addConfirmAction() {
        confirmActionView.customizeAppearance(theme.confirmAction)

        contentView.addSubview(confirmActionView)
        confirmActionView.contentEdgeInsets = theme.confirmActionContentEdgeInsets
        confirmActionView.fitToIntrinsicSize()
        confirmActionView.snp.makeConstraints {
            $0.fitToHeight(theme.confirmActionHeight)
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

    private func addPeraFeeInfo() {
        peraFeeInfoView.customize(theme.infoItem)

        contentView.addSubview(peraFeeInfoView)
        peraFeeInfoView.fitToIntrinsicSize()
        peraFeeInfoView.snp.makeConstraints {
            $0.leading == theme.infoSectionPaddings.leading
            $0.bottom == confirmActionView.snp.top - theme.confirmActionEdgeInsets.top
            $0.trailing == theme.infoSectionPaddings.trailing
        }
    }

    private func addExchangeFeeInfo() {
        exchangeFeeInfoView.customize(theme.infoItem)

        contentView.addSubview(exchangeFeeInfoView)
        exchangeFeeInfoView.fitToIntrinsicSize()
        exchangeFeeInfoView.snp.makeConstraints {
            $0.leading == theme.infoSectionPaddings.leading
            $0.bottom == peraFeeInfoView.snp.top - theme.infoSectionItemSpacing
            $0.trailing == theme.infoSectionPaddings.trailing
        }

        exchangeFeeInfoView.startObserving(event: .didTapInfo) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.didTapExchangeFeeInfo)
        }
    }

    private func addMinimumReceivedInfo() {
        minimumReceivedInfoView.customize(theme.infoItem)

        contentView.addSubview(minimumReceivedInfoView)
        minimumReceivedInfoView.fitToIntrinsicSize()
        minimumReceivedInfoView.snp.makeConstraints {
            $0.leading == theme.infoSectionPaddings.leading
            $0.bottom == exchangeFeeInfoView.snp.top - theme.infoSectionItemSpacing
            $0.trailing == theme.infoSectionPaddings.trailing
        }
    }

    private func addPriceImpactInfo() {
        priceImpactInfoView.customize(theme.infoItem)

        contentView.addSubview(priceImpactInfoView)
        priceImpactInfoView.fitToIntrinsicSize()
        priceImpactInfoView.snp.makeConstraints {
            $0.leading == theme.infoSectionPaddings.leading
            $0.bottom == minimumReceivedInfoView.snp.top - theme.infoSectionItemSpacing
            $0.trailing == theme.infoSectionPaddings.trailing
        }

        priceImpactInfoView.startObserving(event: .didTapInfo) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.didTapPriceImpactInfo)
        }
    }

    private func addSlippageInfo() {
        slippageInfoView.customize(theme.infoActionItem)

        contentView.addSubview(slippageInfoView)
        slippageInfoView.fitToIntrinsicSize()
        slippageInfoView.snp.makeConstraints {
            $0.leading == theme.infoSectionPaddings.leading
            $0.bottom == priceImpactInfoView.snp.top - theme.infoSectionItemSpacing
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

    private func addPriceInfo() {
        priceInfoView.customize(theme.infoActionItem)

        contentView.addSubview(priceInfoView)
        priceInfoView.fitToIntrinsicSize()
        priceInfoView.snp.makeConstraints {
            $0.leading == theme.infoSectionPaddings.leading
            $0.bottom == slippageInfoView.snp.top - theme.infoSectionItemSpacing
            $0.trailing == theme.infoSectionPaddings.trailing
        }

        priceInfoView.startObserving(event: .didTapAction) {
            [weak self] in
            guard let self = self else { return }

            self.switchPriceValuePresentation()
        }

        poolAssetBottomSeparator = contentView.attachSeparator(
            theme.assetSeparator,
            to: priceInfoView,
            margin: theme.infoSectionPaddings.top
        )
    }

	private func addPoolAsset() {
        guard let poolAssetBottomSeparator else { return }
        poolAssetView.customize(theme.poolAsset)

        contentView.addSubview(poolAssetView)
        poolAssetView.fitToIntrinsicSize()
        poolAssetView.snp.makeConstraints {
            $0.top == toSeparatorView.snp.bottom + theme.poolAssetTopInset
            $0.leading == theme.assetHorizontalInset
            $0.bottom >= poolAssetBottomSeparator.snp.top - theme.assetSeparatorPadding
            $0.bottom <= poolAssetBottomSeparator.snp.top - theme.minimumPoolAssetPadding
            $0.trailing == theme.assetHorizontalInset
        }
	}
}

extension ConfirmSwapScreen {
    private func updateUIWhenWillUpdateSlippage() {
        confirmActionView.startLoading()
    }

    private func updateUIWhenDidUpdateSlippage(
        _ quote: SwapQuote
    ) {
        confirmActionView.stopLoading()
        bannerController?.presentSuccessBanner(title: "swap-confirm-slippage-updated-title".localized)
        bindData(quote)
    }

    private func updateUIWhenDidFailToUpdateSlippage(
        _ error: HIPNetworkError<HIPAPIError>
    ) {
        confirmActionView.stopLoading()
        displayError(error.prettyDescription)
    }

    private func updateUIWhenWillPrepareTransactions() {
        confirmActionView.startLoading()
    }

    private func updateUIWhenDidPrepareTransactions(
        _ swapTransactionPreparation: SwapTransactionPreparation
    ) {
        confirmActionView.stopLoading()
        eventHandler?(.didTapConfirm(swapTransactionPreparation))
    }

    private func updateUIWhenDidFailToPrepareTransactions(
        _ error: HIPNetworkError<HIPAPIError>
    ) {
        confirmActionView.stopLoading()
        displayError(error.prettyDescription)
    }
}

extension ConfirmSwapScreen {
    func bindData(
        _ quote: SwapQuote
    ) {
        viewModel = ConfirmSwapScreenViewModel(
            quote: quote,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        userAssetView.bindData(viewModel?.userAsset)
        toSeparatorView.bindData(viewModel?.toSeparator)
        poolAssetView.bindData(viewModel?.poolAsset)
        priceInfoView.bindData(viewModel?.priceInfo)
        slippageInfoView.bindData(viewModel?.slippageInfo)
        priceImpactInfoView.bindData(viewModel?.priceImpactInfo)
        minimumReceivedInfoView.bindData(viewModel?.minimumReceivedInfo)
        exchangeFeeInfoView.bindData(viewModel?.exchangeFeeInfo)
        peraFeeInfoView.bindData(viewModel?.peraFeeInfo)
    }

    private func switchPriceValuePresentation() {
        guard var priceInfoViewModel = viewModel?.priceInfo as? SwapConfirmPriceInfoViewModel else { return }

        isPriceReversed.toggle()

        priceInfoViewModel.bindDetail(
            quote: dataController.quote,
            isPriceReversed: isPriceReversed,
            currencyFormatter: currencyFormatter
        )
        priceInfoView.bindData(priceInfoViewModel)
    }

    private func displayError(
        _ message: String
    ) {
        bannerController?.presentErrorBanner(
            title: "swap-confirm-failed-title".localized,
            message: message
        )
    }
}

extension ConfirmSwapScreen {
    @objc
    private func copyAccountAddress(
        _ recognizer: UILongPressGestureRecognizer
    ) {
        if recognizer.state == .began {
            copyToClipboardController.copyAddress(dataController.account)
        }
    }

    @objc
    private func confirmSwap() {
        dataController.confirmSwap()
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
