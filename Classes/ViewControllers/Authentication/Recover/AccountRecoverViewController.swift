// Copyright 2019 Algorand, Inc.

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
import SVProgressHUD

class AccountRecoverViewController: BaseScrollViewController {

    private let layout = Layout<LayoutConstants>()

    private lazy var inputSuggestionsViewController: InputSuggestionViewController = {
        let inputSuggestionViewController = InputSuggestionViewController(configuration: configuration)
        inputSuggestionViewController.view.frame = layout.current.inputSuggestionsFrame
        return inputSuggestionViewController
    }()

    private var keyboardController = KeyboardController()
    
    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 338.0))
    )
    
    private lazy var accountRecoverView = AccountRecoverView()

    private var viewModel = AccountRecoverViewModel()

    private lazy var recoverButton = MainButton(title: "recover-title".localized)
    
    private lazy var accountManager: AccountManager? = {
        guard let api = self.api else {
            return nil
        }
        let manager = AccountManager(api: api)
        return manager
    }()

    private lazy var dataController: AccountRecoverDataController = {
        guard let session = self.session else {
            fatalError("Session should be set")
        }
        let dataController = AccountRecoverDataController(session: session)
        return dataController
    }()
    
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
        viewModel.currentInputView?.beginEditing()
    }

    override func configureAppearance() {
        super.configureAppearance()
        viewModel.addInputViews(to: accountRecoverView)
        recoverButton.isEnabled = false
    }

    override func linkInteractors() {
        super.linkInteractors()
        viewModel.delegate = self
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
        setupAccountRecoverViewLayout()
        setupRecoverButtonLayout()
    }
}

extension AccountRecoverViewController {
    private func setupAccountRecoverViewLayout() {
        contentView.addSubview(accountRecoverView)
        
        accountRecoverView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.inputViewHeight)
            make.bottom.equalToSuperview()
        }
    }

    private func setupRecoverButtonLayout() {
        view.addSubview(recoverButton)

        recoverButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview().inset(layout.current.defaultInset + view.safeAreaBottom)
        }
    }
}

extension AccountRecoverViewController {
    private func setKeyboardNotificationListeners() {
        keyboardController.notificationHandlerWhenKeyboardShown = { keyboard in
            self.updateRecoverButtonLayoutWhenKeyboardIsShown(keyboard)
        }

        keyboardController.notificationHandlerWhenKeyboardHidden = { keyboard in
            self.updateRecoverButtonLayoutWhenKeyboardIsHidden()
        }
    }

    private func updateRecoverButtonLayoutWhenKeyboardIsShown(_ keyboard: KeyboardController.UserInfo) {
        recoverButton.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.defaultInset + keyboard.height)
        }
    }

    private func updateRecoverButtonLayoutWhenKeyboardIsHidden() {
        recoverButton.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.defaultInset + view.safeAreaBottom)
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
        rightBarButtonItems = [composeQRBarButton(), composePasteBarButton()]
    }

    private func composeQRBarButton() -> ALGBarButtonItem {
        let qrBarButtonItem = ALGBarButtonItem(kind: .qr) { [weak self] in
            guard let self = self else {
                return
            }
            self.openQRScanner()
        }

        return qrBarButtonItem
    }

    private func composePasteBarButton() -> ALGBarButtonItem {
        let pasteBarButtonItem = ALGBarButtonItem(kind: .paste) { [weak self] in
            guard let self = self else {
                return
            }
            self.pasteFromClipboardIfPossible()
        }

        return pasteBarButtonItem
    }
}

extension AccountRecoverViewController {
    private func openQRScanner() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displaySimpleAlertWith(title: "qr-scan-error-title".localized, message: "qr-scan-error-message".localized)
            return
        }

        let controller = open(.qrScanner, by: .push) as? QRScannerViewController
        controller?.delegate = self
    }

    private func recoverAccount() {
        guard let mnemonics = viewModel.getMnemonics() else {
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
            viewModel.updateMnemonicsFromPasteboard(copiedText)
            recoverButton.isEnabled = viewModel.isRecoverEnabled
        }
    }
}

extension AccountRecoverViewController: AccountRecoverViewModelDelegate {
    func accountRecoverViewModel(_ viewModel: AccountRecoverViewModel, didChangeInputIn view: RecoverInputView) {
        customizeRecoverInputViewWhenTheInputWasChanged(view)
    }

    private func customizeRecoverInputViewWhenTheInputWasChanged(_ view: RecoverInputView) {
        recoverButton.isEnabled = viewModel.isRecoverEnabled
        updateRecoverInputSuggestor(in: view)
        inputSuggestionsViewController.findTopSuggestions(for: view.input)
        updateRecoverInputViewStateForSuggestions(view)
    }

    private func updateRecoverInputSuggestor(in view: RecoverInputView) {
        if !view.isInputAccessoryViewSet {
            if !view.input.isNilOrEmpty {
                view.setInputAccessoryView(inputSuggestionsViewController.view)
           } else {
                view.removeInputAccessoryView()
           }
        }
    }

    private func updateRecoverInputViewStateForSuggestions(_ view: RecoverInputView) {
        if !inputSuggestionsViewController.hasSuggestions && !view.input.isNilOrEmpty {
            view.bind(RecoverInputViewModel(state: .wrong, index: view.tag))
        } else {
            view.bind(RecoverInputViewModel(state: .active, index: view.tag))
        }
    }

    func accountRecoverViewModelDidRecover(_ viewModel: AccountRecoverViewModel) {
        recoverAccount()
    }

    func accountRecoverViewModelDidFailedPastingFromClipboard(_ viewModel: AccountRecoverViewModel) {
        NotificationBanner.showError("title-error".localized, message: "recover-copy-error".localized)
    }

    func accountRecoverViewModel(_ viewModel: AccountRecoverViewModel, hasValidSuggestionFor view: RecoverInputView) -> Bool {
        guard let input = view.input,
              !input.isEmptyOrBlank else {
            return false
        }

        return inputSuggestionsViewController.hasMatchingSuggestion(with: input)
    }
}

extension AccountRecoverViewController: AccountRecoverDataControllerDelegate {
    func accountRecoverDataController(
        _ accountRecoverDataController: AccountRecoverDataController,
        didRecover account: AccountInformation
    ) {
        log(RegistrationEvent(type: .recover))
        openSuccessfulRecoverModal(for: account)
    }

    func accountRecoverDataController(
        _ accountRecoverDataController: AccountRecoverDataController,
        didFailRecoveringWith error: AccountRecoverDataController.RecoverError
    ) {
        displayRecoverError(error)
    }

    private func openSuccessfulRecoverModal(for recoveredAccount: AccountInformation) {
        let configurator = BottomInformationBundle(
            title: "recover-from-seed-verify-pop-up-title".localized,
            image: img("img-green-checkmark"),
            explanation: "recover-from-seed-verify-pop-up-explanation".localized,
            actionTitle: "title-go-home".localized,
            actionImage: img("bg-main-button")) {
                self.launchHome(with: recoveredAccount)
        }

        open(
            .bottomInformation(mode: .confirmation, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: bottomModalPresenter
            )
        )
    }

    private func launchHome(with account: AccountInformation) {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        accountManager?.fetchAllAccounts(isVerifiedAssetsIncluded: true) {
            SVProgressHUD.showSuccess(withStatus: "title-done".localized)
            SVProgressHUD.dismiss(withDelay: 1.0) {
                switch self.accountSetupFlow {
                case .initializeAccount:
                    DispatchQueue.main.async {
                        self.dismiss(animated: false) {
                            UIApplication.shared.rootViewController()?.setupTabBarController()
                        }
                    }
                case .addNewAccount:
                    self.closeScreen(by: .dismiss, animated: false)
                }
            }
        }
    }

    private func displayRecoverError(_ error: AccountRecoverDataController.RecoverError) {
        switch error {
        case .alreadyExist:
            NotificationBanner.showError("title-error".localized, message: "recover-from-seed-verify-exist-error".localized)
        case .invalid:
            NotificationBanner.showError(
                "passphrase-verify-invalid-title".localized,
                message: "pass-phrase-verify-invalid-passphrase".localized
            )
        case .sdk:
            NotificationBanner.showError("title-error".localized, message: "pass-phrase-verify-sdk-error".localized)
        }
    }
}

extension AccountRecoverViewController: InputSuggestionViewControllerDelegate {
    func inputSuggestionViewController(_ inputSuggestionViewController: InputSuggestionViewController, didSelect mnemonic: String) {
        viewModel.updateCurrentInputView(with: mnemonic)
    }
}

extension AccountRecoverViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {
        guard qrText.mode == .mnemonic else {
            displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-mnemonics-message".localized) { _ in
                if let handler = completionHandler {
                    handler()
                }
            }
            
            return
        }

        updateScreenFromQR(with: qrText)
    }

    private func updateScreenFromQR(with qrText: QRText) {
        let mnemonics = qrText.qrText().split(separator: " ").map { String($0) }
        viewModel.fillMnemonics(mnemonics)
        recoverButton.isEnabled = true
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = completionHandler {
                handler()
            }
        }
    }
}

extension AccountRecoverViewController: KeyboardControllerDataSource {
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return layout.current.keyboardInset
    }

    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return viewModel.currentInputView
    }

    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }

    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return layout.current.defaultInset
    }
}

extension AccountRecoverViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let inputSuggestionsFrame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 44.0)
        let keyboardInset: CGFloat = 92.0
        let inputViewHeight: CGFloat = 732.0
    }
}
