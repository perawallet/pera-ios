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

//   ConfirmSwapSummaryScreen.swift

import MacaroonBottomSheet
import MacaroonUIKit
import UIKit

final class ConfirmSwapSummaryScreen:
    BaseScrollViewController,
    BottomSheetScrollPresentable {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    var modalHeight: ModalHeight {
        return .compressed
    }

    private lazy var accountInfoView = SecondaryListItemView()
    private lazy var priceInfoView = SwapInfoActionItemView()
    private lazy var slippageInfoView = SwapInfoItemView()
    private lazy var priceImpactInfoView = SwapInfoItemView()
    private lazy var minimumReceivedInfoView = SwapInfoItemView()
    private lazy var exchangeFeeInfoView = SwapInfoItemView()
    private lazy var peraFeeInfoView = SwapInfoItemView()
    private lazy var totalSwapFeeInfoView = SwapInfoItemView()
    private lazy var totalSwapFeeDetailView = UILabel()

    private let swapAssetController: SwapAssetController
    private let theme: ConfirmSwapSummaryScreenTheme

    init(
        swapAssetController: SwapAssetController,
        theme: ConfirmSwapSummaryScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.swapAssetController = swapAssetController
        self.theme = theme
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "swap-confirm-summary-title".localized
    }

    override func prepareLayout() {
        super.prepareLayout()
        addAccountInfo()
        addPriceInfo()
        addSlippageInfo()
        addPriceImpactInfo()
        addMinimumReceivedInfo()
        addExchangeFeeInfo()
        addPeraFeeInfo()
        addTotalSwapFeeInfo()
        addTotalSwapFeeDetail()
    }

    override func bindData() {
        super.bindData()

        let viewModel = ConfirmSwapSummaryScreenViewModel(
            account: swapAssetController.account,
            quote: swapAssetController.quote!
        )

        accountInfoView.bindData(viewModel.accountInfo)
        priceInfoView.bindData(viewModel.priceInfo)
        slippageInfoView.bindData(viewModel.slippageInfo)
        priceImpactInfoView.bindData(viewModel.priceImpactInfo)
        minimumReceivedInfoView.bindData(viewModel.minimumReceivedInfo)
        exchangeFeeInfoView.bindData(viewModel.exchangeFeeInfo)
        peraFeeInfoView.bindData(viewModel.peraFeeInfo)
        totalSwapFeeInfoView.bindData(viewModel.totalSwapFeeInfo)
    }
}

extension ConfirmSwapSummaryScreen {
    private func addAccountInfo() {
        accountInfoView.customize(theme.accountInfo)

        contentView.addSubview(accountInfoView)
        accountInfoView.fitToIntrinsicSize()
        accountInfoView.snp.makeConstraints {
            $0.top == theme.accountInfoTopInset
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addPriceInfo() {
        priceInfoView.customize(theme.infoActionItem)

        let topSeparator = contentView.attachSeparator(
            theme.separator,
            to: accountInfoView,
            margin: theme.accountSeparatorSpacing
        )

        contentView.addSubview(priceInfoView)
        priceInfoView.fitToIntrinsicSize()
        priceInfoView.snp.makeConstraints {
            $0.top == topSeparator.snp.bottom + theme.spacingBetweenSeparatorAndInfo
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset
        }

        priceInfoView.startObserving(event: .didTapAction) {
            [weak self] in
            guard let self = self else { return }

            self.eventHandler?(.didTapPriceAction)
        }
    }

    private func addSlippageInfo() {
        slippageInfoView.customize(theme.infoItem)

        contentView.addSubview(slippageInfoView)
        slippageInfoView.fitToIntrinsicSize()
        slippageInfoView.snp.makeConstraints {
            $0.top == priceInfoView.snp.bottom + theme.itemVerticalInset
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset
        }
    }

    private func addPriceImpactInfo() {
        priceImpactInfoView.customize(theme.infoItem)

        contentView.addSubview(priceImpactInfoView)
        priceImpactInfoView.fitToIntrinsicSize()
        priceImpactInfoView.snp.makeConstraints {
            $0.top == slippageInfoView.snp.bottom + theme.itemVerticalInset
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset
        }
    }

    private func addMinimumReceivedInfo() {
        minimumReceivedInfoView.customize(theme.infoItem)

        contentView.addSubview(minimumReceivedInfoView)
        minimumReceivedInfoView.fitToIntrinsicSize()
        minimumReceivedInfoView.snp.makeConstraints {
            $0.top == priceImpactInfoView.snp.bottom + theme.itemVerticalInset
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset
        }
    }

    private func addExchangeFeeInfo() {
        exchangeFeeInfoView.customize(theme.infoItem)

        let topSeparator = contentView.attachSeparator(
            theme.separator,
            to: minimumReceivedInfoView,
            margin: theme.spacingBetweenSeparatorAndInfo
        )

        contentView.addSubview(exchangeFeeInfoView)
        exchangeFeeInfoView.fitToIntrinsicSize()
        exchangeFeeInfoView.snp.makeConstraints {
            $0.top == topSeparator.snp.bottom + theme.spacingBetweenSeparatorAndInfo
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset
        }
    }

    private func addPeraFeeInfo() {
        peraFeeInfoView.customize(theme.infoItem)

        contentView.addSubview(peraFeeInfoView)
        peraFeeInfoView.fitToIntrinsicSize()
        peraFeeInfoView.snp.makeConstraints {
            $0.top == exchangeFeeInfoView.snp.bottom + theme.itemVerticalInset
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset
        }
    }

    private func addTotalSwapFeeInfo() {
        totalSwapFeeInfoView.customize(theme.infoItem)

        contentView.addSubview(totalSwapFeeInfoView)
        totalSwapFeeInfoView.fitToIntrinsicSize()
        totalSwapFeeInfoView.snp.makeConstraints {
            $0.top == peraFeeInfoView.snp.bottom + theme.itemVerticalInset
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset
        }
    }

    private func addTotalSwapFeeDetail() {
        totalSwapFeeDetailView.customizeAppearance(theme.totalSwapFeeDetail)

        contentView.addSubview(totalSwapFeeDetailView)
        totalSwapFeeDetailView.fitToIntrinsicSize()
        totalSwapFeeDetailView.snp.makeConstraints {
            $0.top == totalSwapFeeInfoView.snp.bottom + theme.totalSwapFeeTopInset
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset

            let bottomInset =
                view.compactSafeAreaInsets.bottom +
                (navigationController ?? self).additionalSafeAreaInsets.bottom
                + theme.itemVerticalInset
            $0.bottom == bottomInset
        }
    }
}

extension ConfirmSwapSummaryScreen {
    @objc
    private func didTapPriceAction() {
        eventHandler?(.didTapPriceAction)
    }
}

extension ConfirmSwapSummaryScreen {
    enum Event {
        case didTapPriceAction
    }
}
