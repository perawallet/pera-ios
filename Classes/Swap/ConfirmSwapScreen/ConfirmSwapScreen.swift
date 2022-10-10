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

import MacaroonForm
import MacaroonUIKit
import UIKit

final class ConfirmSwapScreen:
    BaseScrollViewController,
    NavigationBarLargeTitleConfigurable {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    var navigationBarScrollView: UIScrollView {
        return scrollView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = createNavigationBarLargeTitleView()

    private lazy var navigationBarLargeTitleController = NavigationBarLargeTitleController(screen: self)

    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        presentingScreen: self,
        account: dataController.account
    )

    private lazy var userAssetView = SwapAssetAmountView()
    private lazy var toSeparatorView = TitleSeparatorView()
    private lazy var poolAssetView = SwapAssetAmountView()
    private lazy var infoContextView = MacaroonUIKit.VStackView()
    private lazy var priceInfoView = SwapInfoActionItemView()
    private lazy var slippageInfoView = SwapInfoActionItemView()
    private lazy var priceImpactInfoView = SwapInfoItemView()
    private lazy var minimumReceivedInfoView = SwapInfoItemView()
    private lazy var totalSwapFeeInfoView = SwapInfoItemView()
    private lazy var viewSummaryActionView = MacaroonUIKit.Button()
    private lazy var confirmActionView = MacaroonUIKit.Button()

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

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        navigationBarLargeTitleController.title = "swap-confirm-title".localized
    }

    override func prepareLayout() {
        super.prepareLayout()
        addUserAsset()
        addToSeparator()
        addPoolAsset()
        addInfoContex()
        addViewSummaryAction()
        addConfirmAction()
    }

    override func setListeners() {
        super.setListeners()
        navigationBarLargeTitleController.activate()
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

        contentView.addSubview(userAssetView)
        poolAssetView.fitToIntrinsicSize()
        poolAssetView.snp.makeConstraints {
            $0.top == toSeparatorView.snp.bottom + theme.poolAssetTopInset
            $0.leading == theme.assetHorizontalInset
            $0.trailing == theme.assetHorizontalInset
        }

        contentView.attachSeparator(
            theme.assetSeparator,
            to: poolAssetView,
            margin: theme.assetSeparatorPadding
        )
	}

    private func addInfoContex() {
        contentView.addSubview(infoContextView)
        infoContextView.spacing = theme.infoSectionItemSpacing
        infoContextView.snp.makeConstraints {
            $0.top == toSeparatorView.snp.bottom + theme.poolAssetTopInset
            $0.leading == theme.assetHorizontalInset
            $0.trailing == theme.assetHorizontalInset
        }

        addPriceInfo()
        addSlippageInfo()
        addPriceImpactInfo()
        addMinimumReceivedInfo()
        addTotalSwapFeeInfo()
    }

    private func addPriceInfo() {
        infoContextView.addArrangedSubview(priceInfoView)
        priceInfoView.customize(theme.infoActionItem)

        priceInfoView.startObserving(event: .didTapAction) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.didTapPriceAction)
        }
    }

    private func addSlippageInfo() {
        infoContextView.addArrangedSubview(slippageInfoView)
        slippageInfoView.customize(theme.infoActionItem)

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
        infoContextView.addArrangedSubview(priceImpactInfoView)
        priceImpactInfoView.customize(theme.infoItem)

        priceImpactInfoView.startObserving(event: .didTapInfo) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.didTapPriceImpactInfo)
        }
    }

    private func addMinimumReceivedInfo() {
        infoContextView.addArrangedSubview(minimumReceivedInfoView)
        minimumReceivedInfoView.customize(theme.infoItem)
    }

    private func addTotalSwapFeeInfo() {
        infoContextView.addArrangedSubview(totalSwapFeeInfoView)
        totalSwapFeeInfoView.customize(theme.infoItem)
    }

    private func addViewSummaryAction() {
        contentView.addSubview(viewSummaryActionView)
        viewSummaryActionView.fitToIntrinsicSize()
        viewSummaryActionView.snp.makeConstraints {
            $0.top == infoContextView.snp.bottom + theme.infoSectionItemSpacing
            $0.leading == theme.infoSectionPaddings.leading
            $0.trailing == theme.infoSectionPaddings.trailing
        }

        viewSummaryActionView.addTouch(
            target: self,
            action: #selector(viewSummary)
        )
    }

	private func addConfirmAction() {
        confirmActionView.customizeAppearance(theme.confirmAction)

        contentView.addSubview(confirmActionView)
        confirmActionView.contentEdgeInsets = theme.confirmActionContentEdgeInsets
        confirmActionView.fitToIntrinsicSize()
        confirmActionView.snp.makeConstraints {
            $0.top >= viewSummaryActionView.snp.bottom + theme.confirmActionEdgeInsets.top
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
        let viewModel = ConfirmSwapScreenViewModel(quote)
        userAssetView.bindData(viewModel.userAsset)
        toSeparatorView.bindData(viewModel.toSeparator)
        poolAssetView.bindData(viewModel.poolAsset)
        priceInfoView.bindData(viewModel.priceInfo)
        slippageInfoView.bindData(viewModel.slippageInfo)
        priceImpactInfoView.bindData(viewModel.priceImpactInfo)
        minimumReceivedInfoView.bindData(viewModel.minimumReceivedInfo)
        totalSwapFeeInfoView.bindData(viewModel.totalSwapFeeInfo)
    }
}

extension ConfirmSwapScreen {
    @objc
    private func confirmSwap() {
        eventHandler?(.didTapConfirm)
    }

    @objc
    private func viewSummary() {
        eventHandler?(.didTapViewSummary)
    }
}

extension ConfirmSwapScreen {
    enum Event {
        case didTapConfirm
        case didTapViewSummary
        case didTapPriceAction
        case didTapSlippageInfo
        case didTapSlippageAction
        case didTapPriceImpactInfo
    }
}
