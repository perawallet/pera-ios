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

//   FetchErrorBannerController.swift

import Foundation
import SnapKit
import UIKit
import MacaroonUIKit

final class FetchErrorBannerController {
    private var isPresenting = false
    private var contentView: UIView?

    private unowned let presentingView: UIView

    var configuration: FetchErrorBannerControllerConfiguration

    private var currentContentLayoutAnimator: UIViewPropertyAnimator?

    private var contentStartLayout: [Constraint] = []
    private var contentEndLayout: [Constraint] = []

    init(
        presentingView: UIView,
        configuration: FetchErrorBannerControllerConfiguration = .default
    ) {
        self.presentingView = presentingView
        self.configuration = configuration
    }

    func presentFetchError(
        icon: UIImage = "icon-info-24".uiImage,
        title: String,
        message: String,
        actionTitle: String? = nil,
        actionHandler: (() -> Void)? = nil
    ) {
        if let currentContentLayoutAnimator = currentContentLayoutAnimator,
           currentContentLayoutAnimator.isRunning {
            currentContentLayoutAnimator.isReversed.toggle()
            return
        }

        if isPresenting {
            return
        }

        let view = makeFetchErrorBanner(
            contentBottomPadding: configuration.contentBottomPadding
        )

        let draft = FetchErrorBannerDraft(
            icon: icon,
            title: title,
            message: message,
            actionTitle: actionTitle
        )
        view.bindData(FetchErrorBannerWithActionViewModel(draft))

        if let actionHandler = actionHandler {
            view.observe(event: .performAction, handler: actionHandler)
        }

        addContent(view)

        presentingView.layoutIfNeeded()

        updateLayoutWhenPresentingStatusDidChange(isPresenting: true)
        currentContentLayoutAnimator = makeContentLayoutAnimator(isPresenting: true)

        currentContentLayoutAnimator?.addCompletion {
            [weak self] position in
            guard let self = self else { return }

            switch position {
            case .start:
                self.updateContentLayoutWhenPresentingStatusDidChange(isPresenting: false)
            case .end:
                self.isPresenting = true
            default:
                break
            }
        }

        currentContentLayoutAnimator?.startAnimation()
    }

    func dismissFetchError() {
        if let currentContentLayoutAnimator = currentContentLayoutAnimator,
           currentContentLayoutAnimator.isRunning {
            currentContentLayoutAnimator.isReversed.toggle()
            return
        }

        if !isPresenting {
            return
        }

        updateLayoutWhenPresentingStatusDidChange(isPresenting: false)
        currentContentLayoutAnimator = makeContentLayoutAnimator(isPresenting: false)

        currentContentLayoutAnimator?.addCompletion {
            [weak self] position in
            guard let self = self else { return }

            switch position {
            case .start:
                self.updateLayoutWhenPresentingStatusDidChange(isPresenting: true)
            case .end:
                self.removeLayout()
                self.isPresenting = false
            default:
                break
            }
        }

        currentContentLayoutAnimator?.startAnimation()
    }
}

extension FetchErrorBannerController {
    private func makeContentLayoutAnimator(
        isPresenting: Bool
    ) -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(
            duration: 0.5,
            dampingRatio: 0.8
        ) { [unowned self] in
            presentingView.layoutIfNeeded()
        }
    }
}

extension FetchErrorBannerController {
    private func updateLayoutWhenPresentingStatusDidChange(
        isPresenting: Bool
    ) {
        updateContentLayoutWhenPresentingStatusDidChange(
            isPresenting: isPresenting
        )
    }

    private func removeLayout() {
        removeContent()
    }

    private func addContent(
        _ view: UIView
    ) {
        presentingView.addSubview(
            view
        )

        view.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
        }

        view.snp.prepareConstraints {
            contentStartLayout =  [
                $0.bottom == presentingView.snp.bottom - configuration.bottomMargin
            ]
            contentEndLayout = [
                $0.top == presentingView.snp.bottom
            ]
        }

        updateLayoutWhenPresentingStatusDidChange(
            isPresenting: false
        )

        contentView = view
    }

    private func updateContentLayoutWhenPresentingStatusDidChange(
        isPresenting: Bool
    ) {
        let currentLayout: [Constraint]
        let nextLayout: [Constraint]

        if isPresenting {
            currentLayout = contentEndLayout
            nextLayout = contentStartLayout
        } else {
            currentLayout = contentStartLayout
            nextLayout = contentEndLayout
        }

        currentLayout.deactivate()
        nextLayout.activate()
    }

    private func removeContent() {
        contentView?.removeFromSuperview()
        contentView = nil

        contentStartLayout = []
        contentEndLayout = []
    }
}

extension FetchErrorBannerController {
    private func makeFetchErrorBanner(
        contentBottomPadding: LayoutMetric
    ) -> BannerWithActionView {
        let view = BannerWithActionView()
        view.customize(
            BannerWithActionViewTheme(
                .current,
                contentBottomPadding: contentBottomPadding
            )
        )
        return view
    }
}
