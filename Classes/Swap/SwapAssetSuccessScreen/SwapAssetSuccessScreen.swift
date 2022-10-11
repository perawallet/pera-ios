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

//   SwapAssetSuccessScreen.swift

import MacaroonUIKit
import UIKit

final class SwapAssetSuccessScreen: BaseViewController {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var successIconView = UIImageView()
    private lazy var titleView = UILabel()
    private lazy var detailView = UILabel()
    private lazy var viewDetailActionView = UIButton()
    private lazy var summaryActionView = UIButton()
    private lazy var doneActionView = MacaroonUIKit.Button()

    private let swapAssetController: SwapAssetController
    private let theme: SwapAssetSuccessScreenTheme

    init(
        swapAssetController: SwapAssetController,
        theme: SwapAssetSuccessScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.swapAssetController = swapAssetController
        self.theme = theme
        super.init(configuration: configuration)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addTitle()
        addSuccessIcon()
        addDetail()
        addDoneAction()
        addSummaryAction()
        addViewDetailAction()
    }

    override func setListeners() {
        super.setListeners()
    }

    override func bindData() {
        super.bindData()

        guard let quote = swapAssetController.quote else { return }

        let viewModel = SwapAssetSuccessScreenViewModel(quote)
        viewModel.title?.load(in: titleView)
        viewModel.detail?.load(in: detailView)
    }
}

extension SwapAssetSuccessScreen {
    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        view.addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.center == 0
            $0.leading == theme.titleHorizontalInset
            $0.trailing == theme.titleHorizontalInset
        }
    }

    private func addSuccessIcon() {
        successIconView.customizeAppearance(theme.icon)

        view.addSubview(successIconView)
        successIconView.fitToIntrinsicSize()
        successIconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.centerX == 0
            $0.bottom == titleView.snp.top + theme.spacingBetweenIconAndTitle
        }
    }

    private func addDetail() {
        detailView.customizeAppearance(theme.detail)

        view.addSubview(detailView)
        detailView.fitToIntrinsicSize()
        detailView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndDetail
            $0.leading == theme.spacingBetweenTitleAndDetail
            $0.trailing == theme.spacingBetweenTitleAndDetail
        }
    }

    private func addDoneAction() {
        doneActionView.customizeAppearance(theme.doneAction)
        doneActionView.contentEdgeInsets = UIEdgeInsets(theme.doneActionContentEdgeInsets)

        view.addSubview(doneActionView)
        doneActionView.snp.makeConstraints {
            $0.leading == theme.doneActionEdgeInsets.leading
            $0.trailing == theme.doneActionEdgeInsets.trailing
            $0.bottom == theme.doneActionEdgeInsets.bottom
        }

        doneActionView.addTouch(
            target: self,
            action: #selector(didTapDoneAction)
        )
    }

    private func addSummaryAction() {
        summaryActionView.customizeAppearance(theme.summaryAction)

        view.addSubview(summaryActionView)
        summaryActionView.fitToIntrinsicSize()
        summaryActionView.snp.makeConstraints {
            $0.leading == theme.summaryActionHorizontalInset
            $0.bottom == doneActionView.snp.top - theme.spacingBetweenSummaryActionAndDoneAction
            $0.trailing == theme.summaryActionHorizontalInset
        }

        view.attachSeparator(
            theme.separator,
            to: summaryActionView,
            margin: theme.spacingBetweenSeparatorAndSummaryAction
        )
    }

    private func addViewDetailAction() {
        viewDetailActionView.customizeAppearance(theme.viewDetailAction)

        view.addSubview(viewDetailActionView)
        viewDetailActionView.fitToIntrinsicSize()
        viewDetailActionView.snp.makeConstraints {
            $0.top >= detailView.snp.bottom + theme.minimumSpacingBetweenViewDetailActionAndDetail
            $0.leading == theme.viewDetailActionHorizontalInset
            $0.bottom == summaryActionView.snp.top - theme.spacingBetweenViewDetailActionAndSummaryAction
            $0.trailing == theme.viewDetailActionHorizontalInset
        }
    }
}

extension SwapAssetSuccessScreen {
    @objc
    private func didTapViewDetailAction() {
        eventHandler?(.didTapViewDetailAction)
    }

    @objc
    private func didTapDoneAction() {
        eventHandler?(.didTapDoneAction)
    }

    @objc
    private func didTapSummaryAction() {
        eventHandler?(.didTapSummaryAction)
    }
}

extension SwapAssetSuccessScreen {
    enum Event {
        case didTapViewDetailAction
        case didTapDoneAction
        case didTapSummaryAction
    }
}
