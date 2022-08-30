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

//   ExportAccountsDomainConfirmationScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonForm

/// <todo>: Handle keyboard properly
final class ExportAccountsDomainConfirmationScreen:
    MacaroonUIKit.ScrollScreen,
    KeyboardControllerDataSource {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var contextView = ResultView()
    private lazy var bodyView = UILabel()
    private lazy var domainInputView = FloatingTextInputFieldView()
    private lazy var disclaimerIconView = ImageView()
    private lazy var disclaimerTitleView = UILabel()
    private lazy var disclaimerBodyView = UILabel()
    private lazy var peraWebURLContentView = TripleShadowView()
    private lazy var peraWebURLAcccesoryIconView = UIImageView()
    private lazy var peraWebURLView = UILabel()
    private lazy var continueActionView = MacaroonUIKit.Button()

    private lazy var keyboardController = KeyboardController()

    private let theme: ExportAccountsDomainConfirmationScreenTheme

    init(
        theme: ExportAccountsDomainConfirmationScreenTheme = .init()
    ) {
        self.theme = theme
        super.init()
    }

    deinit {
        keyboardController.endTracking()
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()
        /// <todo> Macaroon
        title = "web-export-accounts-domain-confirmation-title".localized
    }

    override func linkInteractors() {
        super.linkInteractors()

        keyboardController.dataSource = self
        keyboardController.beginTracking()

//        keyboardController.notificationHandlerWhenKeyboardShown = {
//            [weak self] keyboard in
//            self?.footerBackgroundView.snp.updateConstraints {
//                $0.bottom == keyboard.height
//            }
//        }

//        keyboardController.notificationHandlerWhenKeyboardHidden = {
//            [weak self] _ in
//            self?.footerBackgroundView.snp.updateConstraints {
//                $0.bottom == 0
//            }
//        }
    }

    override func prepareLayout() {
        super.prepareLayout()

        footerViewEffectStyle = .linearGradient(
            .init(colors: [
                Colors.Defaults.background.uiColor.withAlphaComponent(0),
                Colors.Defaults.background.uiColor
            ])
        )

        addUI()
    }

    private func addUI() {
        addBackground()
        addContext()
        addContinueAction()
    }
}

extension ExportAccountsDomainConfirmationScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextEdgeInsets.top
            $0.leading == theme.contextEdgeInsets.leading
            $0.trailing == theme.contextEdgeInsets.trailing
            $0.bottom == theme.contextEdgeInsets.bottom
        }

        addBody()
        addDomainInput()
        addDisclaimerIcon()
        addDisclaimerTitle()
        addDisclaimerBody()
        addPeraWebURLContent()
    }

    private func addBody() {
        bodyView.customizeAppearance(theme.body)

        contextView.addSubview(bodyView)
        bodyView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addDomainInput() {
        domainInputView.customize(theme.domainInput)

        contextView.addSubview(domainInputView)
        domainInputView.snp.makeConstraints {
            $0.top == bodyView.snp.bottom + theme.spacingBetweenBodyAndDomainInput
            $0.leading == 0
            $0.trailing == 0
            $0.greaterThanHeight(theme.domainInputMinHeight)
        }

        domainInputView.delegate = self
        domainInputView.editingDelegate = self
    }

    private func addDisclaimerIcon() {
        disclaimerIconView.customizeAppearance(theme.disclaimerIcon)
        disclaimerIconView.layer.draw(corner: theme.disclaimerIconCorner)

        disclaimerIconView.contentEdgeInsets = theme.disclaimerIconLayoutOffset
        disclaimerIconView.fitToIntrinsicSize()
        contextView.addSubview(disclaimerIconView)
        disclaimerIconView.snp.makeConstraints {
            $0.top == domainInputView.snp.bottom + theme.spacingBetweenDomainInputAndDisclaimerContent
            $0.leading == 0
        }
    }

    private func addDisclaimerTitle() {
        disclaimerTitleView.customizeAppearance(theme.disclaimerTitle)

        contextView.addSubview(disclaimerTitleView)
        disclaimerTitleView.snp.makeConstraints {
            $0.centerY == disclaimerIconView
            $0.leading == disclaimerIconView.snp.trailing + theme.spacingBetweenDislaimerIconAndDisclaimerTitle
            $0.trailing <= 0
        }
    }

    private func addDisclaimerBody() {
        disclaimerBodyView.customizeAppearance(theme.disclaimerBody)

        contextView.addSubview(disclaimerBodyView)
        disclaimerBodyView.snp.makeConstraints {
            $0.top == disclaimerIconView.snp.bottom + theme.spacingBetweenDisclaimerBodyAndIcon
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addPeraWebURLContent() {
        peraWebURLContentView.drawAppearance(shadow: theme.peraWebURLContentFirstShadow)
        peraWebURLContentView.drawAppearance(secondShadow: theme.peraWebURLContentSecondShadow)
        peraWebURLContentView.drawAppearance(thirdShadow: theme.peraWebURLContentThirdShadow)

        contextView.addSubview(peraWebURLContentView)
        peraWebURLContentView.fitToVerticalIntrinsicSize()
        peraWebURLContentView.snp.makeConstraints {
            $0.top == disclaimerBodyView.snp.bottom + theme.spacingBetweenDisclaimerBodyAndPeraWebURL
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
            $0.greaterThanHeight(theme.peraWebURLContentMinHeight)
        }

        addPeraWebURLAcccesoryIcon()
        addPeraWebURL()
    }

    private func addPeraWebURLAcccesoryIcon() {
        peraWebURLAcccesoryIconView.customizeAppearance(theme.peraWebURLAccessoryIcon)

        peraWebURLContentView.addSubview(peraWebURLAcccesoryIconView)
        peraWebURLAcccesoryIconView.fitToIntrinsicSize()
        peraWebURLAcccesoryIconView.snp.makeConstraints {
            $0.top >= theme.peraWebURLContentEdgeInsets.top
            $0.leading == theme.peraWebURLContentEdgeInsets.leading
            $0.bottom <= theme.peraWebURLContentEdgeInsets.bottom
            $0.centerY == 0
        }
    }

    private func addPeraWebURL() {
        peraWebURLView.customizeAppearance(theme.peraWebURL)

        peraWebURLContentView.addSubview(peraWebURLView)
        peraWebURLView.snp.makeConstraints {
            $0.top >= theme.peraWebURLContentEdgeInsets.top
            $0.leading == peraWebURLAcccesoryIconView.snp.trailing + theme.spacingBetweenPeraWebURLAccessoryAndPeraWebURL
            $0.bottom <= theme.peraWebURLContentEdgeInsets.bottom
            $0.trailing == theme.peraWebURLContentEdgeInsets.trailing
            $0.centerY == 0
        }
    }

    private func addContinueAction() {
        continueActionView.customizeAppearance(theme.continueAction)
        continueActionView.contentEdgeInsets = UIEdgeInsets(theme.continueActionEdgeInsets)

        footerView.addSubview(continueActionView)
        continueActionView.snp.makeConstraints {
            $0.top == theme.continueActionContentEdgeInsets.top
            $0.leading == theme.continueActionContentEdgeInsets.leading
            $0.trailing == theme.continueActionContentEdgeInsets.trailing
            $0.bottom == theme.continueActionContentEdgeInsets.bottom
        }

        continueActionView.addTouch(
            target: self,
            action: #selector(performContinue)
        )

        continueActionView.isEnabled = isContinueActionEnabled
    }
}

extension ExportAccountsDomainConfirmationScreen: FloatingTextInputFieldViewDelegate {
    func floatingTextInputFieldViewShouldReturn(_ view: FloatingTextInputFieldView) -> Bool {
        view.endEditing()
        return true
    }
}

extension ExportAccountsDomainConfirmationScreen: FormInputFieldViewEditingDelegate {
    func formInputFieldViewDidBeginEditing(_ view: FormInputFieldView) {}

    func formInputFieldViewDidEndEditing(_ view: FormInputFieldView) {}

    func formInputFieldViewDidEdit(_ view: FormInputFieldView) {
        continueActionView.isEnabled = isContinueActionEnabled
    }
}

extension ExportAccountsDomainConfirmationScreen {
    var isContinueActionEnabled: Bool {
        let domainInput = domainInputView.text
        let isDomainInputValid =
            domainInput == AlgorandWeb.peraWebApp.rawValue ||
            domainInput == AlgorandWeb.peraWebApp.presentation
        return isDomainInputValid
    }
}

extension ExportAccountsDomainConfirmationScreen {
    func bottomInsetWhenKeyboardPresented(
        for keyboardController: KeyboardController
    ) -> CGFloat {
        return .zero
    }

    func firstResponder(
        for keyboardController: KeyboardController
    ) -> UIView? {
        return domainInputView
    }

    func containerView(
        for keyboardController: KeyboardController
    ) -> UIView {
        return contentView
    }

    func bottomInsetWhenKeyboardDismissed(
        for keyboardController: KeyboardController
    ) -> CGFloat {
        return .zero
    }
}

extension ExportAccountsDomainConfirmationScreen {
    @objc
    private func performContinue() {
        eventHandler?(.performContinue)
    }
}

extension ExportAccountsDomainConfirmationScreen {
    enum Event {
        case performContinue
    }
}
