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

//
//   BannerController.swift

import Foundation
import MacaroonBanner
import MacaroonUIKit
import UIKit

final class BannerController: MacaroonBanner.BannerController {
    init(
        presentingView: UIView
    ) {
        super.init(presentingView: presentingView)

        configuration.contentHorizontalPaddings = (24, 24)
        configuration.contentTopPadding = presentingView.safeAreaInsets.top + 12

        activate()
    }

    func presentErrorBanner(
        title: String,
        message: String,
        icon: UIImage? = "icon-info-24".uiImage
    ) {
        let bannerView = makeErrorBanner()
        let draft = BannerDraft(
            title: title,
            icon: icon,
            description: message
        )

        bannerView.bindData(
            BannerErrorViewModel(draft)
        )

        enqueue(bannerView)
    }

    func presentSuccessBanner(
        title: String,
        message: String? = nil,
        icon: UIImage? = "icon-success-24".uiImage
    ) {
        let bannerView = makeSuccessBanner()
        let draft = BannerDraft(
            title: title,
            icon: icon,
            description: message ?? ""
        )

        bannerView.bindData(
            BannerErrorViewModel(draft)
        )

        enqueue(bannerView)
    }

    func presentNotification(
        _ title: String,
        _ completion: (() -> Void)? = nil
    ) {
        let view = makeNotificationBanner()
        view.bindData(BannerInfoViewModel(title))

        view.observe(event: .performAction) {
            completion?()
        }

        enqueue(view)
    }

    func presentInfoBanner(
        _ title: String,
        _ completion: (() -> Void)? = nil
    ) {
        let view = makeInfoBanner()
        view.bindData(BannerInfoViewModel(title))

        view.observe(event: .performAction) {
            completion?()
        }

        enqueue(view)
    }
}

extension BannerController {
    private func makeErrorBanner() -> BannerView {
        let view = BannerView()
        view.customize(BannerViewTheme())
        return view
    }

    private func makeSuccessBanner() -> BannerView {
        let view = BannerView()
        var theme = BannerViewTheme()
        theme.configureForSuccess()
        view.customize(theme)
        return view
    }

    private func makeNotificationBanner() -> BannerView {
        let view = BannerView()
        var theme = BannerViewTheme()
        theme.configureForNotification()
        view.customize(theme)
        return view
    }

    private func makeInfoBanner() -> BannerView {
        let view = BannerView()
        var theme = BannerViewTheme()
        theme.configureForInfo()
        view.customize(theme)
        return view
    }
}
