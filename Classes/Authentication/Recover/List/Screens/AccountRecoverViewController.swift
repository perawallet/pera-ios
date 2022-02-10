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
//  AccountRecoverViewController.swift

import UIKit

final class AccountRecoverViewController: BaseScrollViewController {
    private lazy var bottomSheetTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var inputSuggestionsViewController: InputSuggestionViewController = {
        let inputSuggestionViewController = InputSuggestionViewController(configuration: configuration)
        inputSuggestionViewController.view.frame = theme.inputSuggestionsFrame
        return inputSuggestionViewController
    }()

    private var keyboardController = KeyboardController()
    
    private lazy var accountRecoverView = AccountRecoverView()
    private lazy var recoverButton = Button()
    private lazy var theme = Theme()

    private var isRecoverEnabled: Bool {
        return getMnemonics() != nil
    }

    private lazy var dataController: AccountRecoverDataController = {
        guard let session = session else {
            fatalError("Session should be set")
        }
        let dataController = AccountRecoverDataController(sharedDataController: sharedDataController, session: session)
        return dataController
    }()

    private var recoverInputViews: [RecoverInputView] {
        return accountRecoverView.recoverInputViews
    }

    private let accountSetupFlow: AccountSetupFlow
    
    init(accountSetupFlow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        accountRecoverView.currentInputView?.beginEditing()
    }

    override func configureAppearance() {
        super.configureAppearance()
        customizeBackground()

        recoverButton.isEnabled = false
    }

    private func customizeBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        scrollView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        contentView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func linkInteractors() {
        super.linkInteractors()
        accountRecoverView.delegate = self
        dataController.delegate = self
        keyboardController.dataSource = self
        inputSuggestionsViewController.delegate = self
    }

    override func setListeners() {
        super.setListeners()
        keyboardController.beginTracking()
        setKeyboardNotificationListeners()
        recoverButton.addTarget(self, action: #selector(triggerRecoverAction), for: .touchUpInside)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addAccountRecoverView()
        addRecoverButton()
    }
}

extension AccountRecoverViewController {
    private func addAccountRecoverView() {
        accountRecoverView.customize(theme.accountRecoverViewTheme)

        contentView.addSubview(accountRecoverView)
        accountRecoverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addRecoverButton() {
        recoverButton.customize(ButtonPrimaryTheme())
        recoverButton.bindData(ButtonCommonViewModel(title: "recover-title".localized))

        view.addSubview(recoverButton)
        recoverButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview().inset(theme.bottomInset + view.safeAreaBottom)
        }
    }
}

extension AccountRecoverViewController {
    private func setKeyboardNotificationListeners() {
        keyboardController.notificationHandlerWhenKeyboardShown = { [weak self] keyboard in
            self?.updateRecoverButtonLayoutWhenKeyboardIsShown(keyboard)
        }

        keyboardController.notificationHandlerWhenKeyboardHidden = { [weak self] _ in
            self?.updateRecoverButtonLayoutWhenKeyboardIsHidden()
        }
    }

    private func updateRecoverButtonLayoutWhenKeyboardIsShown(_ keyboard: KeyboardController.UserInfo) {
        recoverButton.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(theme.bottomInset + keyboard.height)
        }
    }

    private func updateRecoverButtonLayoutWhenKeyboardIsHidden() {
        recoverButton.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(theme.bottomInset + view.safeAreaBottom)
        }
    }
}

extension AccountRecoverViewController {
    @objc
    private func triggerRecoverAction() {
        recoverAccount()
    }
}

extension AccountRecoverViewController {
    private func addBarButtons() {
        let optionsBarButtonItem = ALGBarButtonItem(kind: .options) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.openRecoverOptions()
        }

        rightBarButtonItems = [optionsBarButtonItem]
    }

    private func openRecoverOptions() {
        bottomSheetTransition.perform(
            .recoverOptions(delegate: self),
            by: .presentWithoutNavigationController
        )
    }
}

extension AccountRecoverViewController: AccountRecoverOptionsViewControllerDelegate {
    func accountRecoverOptionsViewControllerDidOpenScanQR(_ viewController: AccountRecoverOptionsViewController) {
        openQRScanner()
    }

    func accountRecoverOptionsViewControllerDidPasteFromClipboard(_ viewController: AccountRecoverOptionsViewController) {
        pasteFromClipboardIfPossible()
    }

    func accountRecoverOptionsViewControllerDidOpenMoreInfo(_ viewController: AccountRecoverOptionsViewController) {
        open(AlgorandWeb.recoverSupport.link)
    }
}

extension AccountRecoverViewController {
    private func openQRScanner() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displaySimpleAlertWith(title: "qr-scan-error-title".localized, message: "qr-scan-error-message".localized)
            return
        }

        let controller = open(.qrScanner(canReadWCSession: false), by: .push) as? QRScannerViewController
        controller?.delegate = self
    }

    private func recoverAccount() {
        guard let mnemonics = getMnemonics() else {
            displaySimpleAlertWith(title: "title-error".localized, message: "recover-fill-all-error".localized)
            return
        }

        view.endEditing(true)
        dataController.recoverAccount(from: mnemonics)
    }
}

extension AccountRecoverViewController {
    private func pasteFromClipboardIfPossible() {
        if let copiedText = UIPasteboard.general.string {
            updateMnemonics(copiedText)
            recoverButton.isEnabled = isRecoverEnabled
        }
    }
}

extension AccountRecoverViewController: AccountRecoverViewDelegate {
    func accountRecoverView(_ view: AccountRecoverView, didBeginEditing recoverInputView: RecoverInputView) {
        if let index = view.index(of: recoverInputView) {
            customizeRecoverInputViewWhenInputDidChange(recoverInputView)
            recoverInputView.bindData(RecoverInputViewModel(state: .active, index: index))
        }
    }

    func accountRecoverView(_ view: AccountRecoverView, didChangeInputIn recoverInputView: RecoverInputView) {
        customizeRecoverInputViewWhenInputDidChange(recoverInputView)
    }

    private func customizeRecoverInputViewWhenInputDidChange(_ view: RecoverInputView) {
        recoverButton.isEnabled = isRecoverEnabled
        inputSuggestionsViewController.findTopSuggestions(for: view.input)
        updateRecoverInputSuggestor(in: view)
        updateRecoverInputViewStateForSuggestions(view)
    }

    private func updateRecoverInputSuggestor(in view: RecoverInputView) {
        if !view.isInputAccessoryViewSet {
            if !view.input.isNilOrEmpty,
               inputSuggestionsViewController.hasSuggestions {
                view.setInputAccessoryView(inputSuggestionsViewController.view)
            }
        } else {
            if !inputSuggestionsViewController.hasSuggestions || view.input.isNilOrEmpty {
                view.removeInputAccessoryView()
            }
        }
    }

    private func updateRecoverInputViewStateForSuggestions(_ view: RecoverInputView) {
        guard let index = accountRecoverView.index(of: view) else {
            return
        }

        if !inputSuggestionsViewController.hasSuggestions && !view.input.isNilOrEmpty {
            view.bindData(RecoverInputViewModel(state: .wrong, index: index))
        } else {
            view.bindData(RecoverInputViewModel(state: .active, index: index))
        }
    }

    func accountRecoverView(_ view: AccountRecoverView, didEndEditing recoverInputView: RecoverInputView) {
        guard let index = view.index(of: recoverInputView) else {
            return
        }

        if recoverInputView.input.isNilOrEmpty {
            recoverInputView.bindData(RecoverInputViewModel(state: .empty, index: index))
        } else if !hasValidSuggestion(for: recoverInputView) {
            recoverInputView.bindData(RecoverInputViewModel(state: .filledWrongly, index: index))
        } else {
            recoverInputView.bindData(RecoverInputViewModel(state: .filled, index: index))
        }
    }

    func accountRecoverView(_ view: AccountRecoverView, shouldReturn recoverInputView: RecoverInputView) -> Bool {
        finishUpdates(for: recoverInputView)
        return true
    }

    func accountRecoverView(
        _ view: AccountRecoverView,
        shouldChange recoverInputView: RecoverInputView,
        charactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        return isValidMnemonicInput(string)
    }
}

extension AccountRecoverViewController {
    private func hasValidSuggestion(for view: RecoverInputView) -> Bool {
        guard let input = view.input,
              !input.isEmptyOrBlank else {
                  return false
              }

        return inputSuggestionsViewController.hasMatchingSuggestion(with: input)
    }

    private func isValidMnemonicInput(_ string: String) -> Bool {
        let mnemonics = string.split(separator: " ").map { String($0) }

        if containsOneMnemonic(mnemonics) {
            return string != " "
        }

        // If copied text is a valid mnemonc, fill automatically.
        if isValidMnemonicCount(mnemonics) {
            fillMnemonics(mnemonics)
            recoverButton.isEnabled = true
            return false
        }

        // Invalid copy/paste action for mnemonics.
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: "recover-copy-error".localized
        )
        return false
    }

    private func containsOneMnemonic(_ mnemonics: [String]) -> Bool {
        return mnemonics.count <= 1
    }

    private func isValidMnemonicCount(_ mnemonics: [String]) -> Bool {
        return mnemonics.count == accountRecoverView.constants.totalMnemonicCount
    }
}

extension AccountRecoverViewController {
    private func getMnemonics() -> String? {
        let inputs = recoverInputViews.compactMap { $0.input }.filter { !$0.isEmpty }
        if inputs.count == accountRecoverView.constants.totalMnemonicCount {
            return inputs.joined(separator: " ")
        }
        return nil
    }

    private func fillMnemonics(_ mnemonics: [String]) {
        for (index, inputView) in recoverInputViews.enumerated() {
            inputView.setText(mnemonics[index])
        }
    }

    private func updateCurrentInputView(with mnemonic: String) {
        guard let currentInputView = accountRecoverView.currentInputView else {
            return
        }

        currentInputView.setText(mnemonic)
        finishUpdates(for: currentInputView)
    }

    private func finishUpdates(for recoverInputView: RecoverInputView) {
        if let nextInputView = recoverInputViews.nextView(of: recoverInputView) as? RecoverInputView {
            nextInputView.beginEditing()
            return
        }

        recoverAccount()
    }
}

extension AccountRecoverViewController {
    private func updateMnemonics(_ text: String) {
        let mnemonics = text.split(separator: " ").map { String($0) }

        if containsOneMnemonic(mnemonics) {
            if let firstText = mnemonics[safe: 0],
               !firstText.trimmed.isEmpty {
                updateCurrentInputView(with: text)
            }
            return
        }

        // If copied text is a valid mnemonic, fill automatically.
        if isValidMnemonicCount(mnemonics) {
            fillMnemonics(mnemonics)
            recoverButton.isEnabled = true
            return
        }

        // Invalid copy/paste action for mnemonics.
        bannerController?.presentErrorBanner(title: "title-error".localized, message: "recover-copy-error".localized)
    }
}

extension AccountRecoverViewController: AccountRecoverDataControllerDelegate {
    func accountRecoverDataController(
        _ accountRecoverDataController: AccountRecoverDataController,
        didRecover account: AccountInformation
    ) {
        log(RegistrationEvent(type: .recover))
        open(.accountNameSetup(flow: accountSetupFlow, mode: .recover, accountAddress: account.address), by: .push)
    }

    func accountRecoverDataController(
        _ accountRecoverDataController: AccountRecoverDataController,
        didFailRecoveringWith error: AccountRecoverDataController.RecoverError
    ) {
        displayRecoverError(error)
    }

    private func displayRecoverError(_ error: AccountRecoverDataController.RecoverError) {
        let errorTitle: String
        let errorDescription: String

        switch error {
        case .alreadyExist:
            errorTitle = "title-error"
            errorDescription = "recover-from-seed-verify-exist-error"
        case .invalid:
            errorTitle = "passphrase-verify-invalid-title"
            errorDescription = "pass-phrase-verify-invalid-passphrase"
        case .sdk:
            errorTitle = "title-error"
            errorDescription = "pass-phrase-verify-sdk-error"
        }

        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-red".uiImage,
            title: errorTitle.localized,
            description: errorDescription.localized,
            secondaryActionButtonTitle: "title-close".localized
        )

        bottomSheetTransition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )
    }
}

extension AccountRecoverViewController: InputSuggestionViewControllerDelegate {
    func inputSuggestionViewController(_ inputSuggestionViewController: InputSuggestionViewController, didSelect mnemonic: String) {
        updateCurrentInputView(with: mnemonic)
    }
}

extension AccountRecoverViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {
        guard qrText.mode == .mnemonic else {
            displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-mnemonics-message".localized) { _ in
                completionHandler?()
            }

            return
        }

        updateScreenFromQR(with: qrText)
    }

    private func updateScreenFromQR(with qrText: QRText) {
        let mnemonics = qrText.qrText().split(separator: " ").map { String($0) }
        fillMnemonics(mnemonics)
        recoverButton.isEnabled = true
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            completionHandler?()
        }
    }
}

extension AccountRecoverViewController: KeyboardControllerDataSource {
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return theme.keyboardInset
    }

    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return accountRecoverView.currentInputView
    }

    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }

    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return theme.bottomInset
    }
}
