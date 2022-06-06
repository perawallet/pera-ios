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

//   HomePortfolioNavigationView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomePortfolioNavigationView: View {
    private lazy var titleView = Label()
    private lazy var subtitleView = Label()

    private var runningTitleVisibilityAnimator: UIViewPropertyAnimator?

    private var isTitleVisible: Bool {
        return titleView.alpha == 1
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {
        addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        subtitleView.customizeBaseAppearance(textColor: AppColors.Components.Text.gray)

        addSubview(subtitleView)
        subtitleView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        setTitleVisible(false)
    }

    func bind(title: String, subtitle: String?) {
        titleView.attributedText = title.bodyMedium()
        subtitleView.attributedText = subtitle?.captionMedium()
    }

    func startAnimationToToggleTitleVisibility(
        visible: Bool
    ) {
        guard visible != isTitleVisible else {
            return
        }

        discardRunningAnimationToToggleTitleVisibility()

        runningTitleVisibilityAnimator =
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: visible ? 0.2 : 0.1,
                delay: 0.0,
                options: visible ? [] : .curveEaseOut,
                animations: {
                    [unowned self] in

                    self.setTitleVisible(
                        visible
                    )
                },
                completion: {
                    [weak self] _ in

                    guard let self = self else {
                        return
                    }

                    self.runningTitleVisibilityAnimator = nil
                }
            )
    }

    private func setTitleVisible(
        _ visible: Bool
    ) {
        titleView.alpha = visible ? 1 : 0
        subtitleView.alpha = visible ? 1 : 0
    }

    private func discardRunningAnimationToToggleTitleVisibility() {
        runningTitleVisibilityAnimator?.stopAnimation(
            false
        )
        runningTitleVisibilityAnimator?.finishAnimation(
            at: .current
        )
        runningTitleVisibilityAnimator = nil
    }
}
