// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WebImportErrorScreen.swift

import Foundation
import MacaroonUIKit

final class WebImportErrorScreen: ScrollScreen {
    typealias EventHandler = (Event, WebImportErrorScreen) -> Void

    override var shouldShowNavigationBar: Bool {
        return false
    }

    var eventHandler: EventHandler?

    private lazy var theme = WebImportErrorScreenTheme()
    private lazy var resultView = ResultView()
    private lazy var goToHomeActionView = MacaroonUIKit.Button()

    override func prepareLayout() {
        super.prepareLayout()

        customizeViewAppearance(theme.background)

        addUI(theme)
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }

    override func bindData() {
        super.bindData()

        resultView.bindData(WebImportErrorViewModel())
    }

    private func addUI(_ theme: WebImportErrorScreenTheme) {
        addResultView(theme)
        addGoToHomeActionView(theme)
    }

    private func addResultView(_ theme: WebImportErrorScreenTheme) {
        resultView.customize(theme.resultViewTheme)
        contentView.addSubview(resultView)
        resultView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(theme.resultViewTopInset)
            make.leading.trailing.equalToSuperview().inset(theme.resultViewHorizontalInset)
        }
    }

    private func addGoToHomeActionView(_ theme: WebImportErrorScreenTheme) {
        goToHomeActionView.customizeAppearance(theme.goToHomeAction)

        footerView.addSubview(goToHomeActionView)
        goToHomeActionView.contentEdgeInsets = theme.goToHomeActionContentEdgeInsets
        goToHomeActionView.snp.makeConstraints {
            $0.top == theme.goToHomeActionEdgeInsets.top
            $0.leading == theme.goToHomeActionEdgeInsets.leading
            $0.bottom == theme.goToHomeActionEdgeInsets.bottom
            $0.trailing == theme.goToHomeActionEdgeInsets.trailing
        }

        goToHomeActionView.addTouch(
            target: self,
            action: #selector(performGoToHomeAction)
        )
    }

    @objc
    private func performGoToHomeAction() {
        eventHandler?(.didGoHome, self)
    }
}

extension WebImportErrorScreen {
    enum Event {
        case didGoHome
    }
}
