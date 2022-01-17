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
//  ChoosePasswordViewController.swift

import UIKit
import AVFoundation

final class ChoosePasswordViewController: BaseViewController {
    private let viewModel: ChoosePasswordViewModel
    private let accountSetupFlow: AccountSetupFlow?
    private let mode: Mode
    private var route: Screen?

    private lazy var choosePasswordView = ChoosePasswordView()
    private lazy var theme = Theme()
    
    private let localAuthenticator = LocalAuthenticator()
    
    private var pinLimitStore = PinLimitStore()

    weak var delegate: ChoosePasswordViewControllerDelegate?
    
    init(mode: Mode, accountSetupFlow: AccountSetupFlow?, route: Screen?, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.accountSetupFlow = accountSetupFlow
        self.route = route
        self.viewModel = ChoosePasswordViewModel(mode)
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayPinLimitScreenIfNeeded()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        setTitle()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupChoosePasswordViewLayout()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        choosePasswordView.linkInteractors()
        choosePasswordView.delegate = self
    }

    override func bindData() {
        super.bindData()
        viewModel.configure(choosePasswordView)
    }
}

extension ChoosePasswordViewController {
    private func setupChoosePasswordViewLayout() {
        choosePasswordView.customize(theme.choosePasswordViewTheme)

        view.addSubview(choosePasswordView)
        choosePasswordView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension ChoosePasswordViewController {
    private func displayPinLimitScreenIfNeeded() {
        if shouldDisplayPinLimitScreen(isFirstLaunch: true) && mode == .login {
            displayPinLimitScreen()
        } else {
            checkLoginFlow()
        }
    }
    
    private func setTitle() {
        switch mode {
        case .verify:
            title = "password-verify-title".localized
        case let .confirm(viewTitle):
            title = viewTitle
        default:
            return
        }
    }
    
    private func checkLoginFlow() {
        if mode == .login {
            if localAuthenticator.localAuthenticationStatus == .allowed {
                localAuthenticator.authenticate { error in
                    guard error == nil else {
                        return
                    }
                    self.launchHome()
                }
            }
            return
        }
    }
    
    private func launchHome() {
        setupRouteFromNotification()

        DispatchQueue.main.async {
            UIApplication.shared.rootViewController()?.tabBarViewController.route = self.route
        }

        dismiss(animated: false) {
            UIApplication.shared.rootViewController()?.setupTabBarController()
        }
    }
    
    private func setupRouteFromNotification() {
        guard let navigationRoute = route else {
            return
        }
        
        switch navigationRoute {
        case let .assetDetailNotification(address, assetId):
            guard let account = session?.account(from: address) else {
                return
            }
            
            var assetDetail: AssetInformation?
            
            if let assetId = assetId {
                assetDetail = account.assetInformations.first { $0.id == assetId }
            }

            guard let accountHandle = sharedDataController.accountCollection[account.address] else {
                return
            }

            if let assetDetail = assetDetail {
                route = .assetDetail(draft: AssetTransactionListing(accountHandle: accountHandle, assetDetail: assetDetail))
            } else {
                route = .algosDetail(draft: AlgoTransactionListing(accountHandle: accountHandle))
            }
        case let .assetActionConfirmationNotification(address, assetId):
            guard let account = session?.account(from: address),
                  let assetId = assetId else {
                return
            }
            
            let draft = AssetAlertDraft(
                account: account,
                assetIndex: assetId,
                assetDetail: nil,
                title: "asset-support-add-title".localized,
                detail: String(
                    format: "asset-support-add-message".localized,
                    "\(account.name ?? "")"
                ),
                actionTitle: "title-approve".localized,
                cancelTitle: "title-cancel".localized
            )
            
            route = .assetActionConfirmation(assetAlertDraft: draft)
        default:
            break
        }
    }
    
    private func displayPinLimitScreen() {
        let controller = open(
            .pinLimit,
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            ),
            animated: false
        ) as? PinLimitViewController
        controller?.delegate = self
    }
    
    private func shouldDisplayPinLimitScreen(isFirstLaunch: Bool) -> Bool {
        let (attemptCount, remainder) = pinLimitStore.attemptCount.quotientAndRemainder(dividingBy: pinLimitStore.allowedAttemptLimitCount)
        if isFirstLaunch {
            return attemptCount > 0 && remainder == 0 && pinLimitStore.remainingTime != 0
        }
        return attemptCount > 0 && remainder == 0
    }
}

extension ChoosePasswordViewController: ChoosePasswordViewDelegate {
    func choosePasswordView(_ choosePasswordView: ChoosePasswordView, didSelect value: NumpadKey) {
        switch mode {
        case .setup:
            openVerifyPassword(with: value)
        case let .verify(previousPassword):
            verifyPassword(with: value, and: previousPassword)
        case .login:
            login(with: value)
        case .deletePassword:
            deletePassword(with: value)
        case .resetPassword:
            openResetVerify(with: value)
        case let .resetVerify(previousPassword):
            verifyResettedPassword(with: value, and: previousPassword)
        case .confirm:
            confirmPassword(with: value)
        }
    }
}

extension ChoosePasswordViewController {
    private func openVerifyPassword(with value: NumpadKey) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            open(.choosePassword(mode: .verify(password), flow: accountSetupFlow, route: nil), by: .push)
        }
    }
    
    private func verifyPassword(with value: NumpadKey, and previousPassword: String) {
        guard let flow = accountSetupFlow else {
            return
        }
        
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            if password != previousPassword {
                displaySimpleAlertWith(title: "password-verify-fail-title".localized, message: "password-verify-fail-message".localized)
                viewModel.reset(choosePasswordView)
                return
            }
            configuration.session?.savePassword(password)
            open(.tutorial(flow: flow, tutorial: .localAuthentication), by: .push)
        }
    }

    private func login(with value: NumpadKey) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            if session?.isPasswordMatching(with: password) ?? false {
                choosePasswordView.numpadView.isUserInteractionEnabled = false
                pinLimitStore.resetPinAttemptCount()
                launchHome()
            } else {
                pinLimitStore.increasePinAttemptCount()
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                viewModel.displayWrongPasswordState(choosePasswordView)
                let (attemptCount, _) = pinLimitStore.attemptCount.quotientAndRemainder(dividingBy: pinLimitStore.allowedAttemptLimitCount)
                if shouldDisplayPinLimitScreen(isFirstLaunch: false) {
                    // Pin limit waiting time increases exponentially with respect to attempt count and 30 seconds.
                    let newRemainingTime = 30 * (pow(2, attemptCount - 1) as NSDecimalNumber).intValue
                    pinLimitStore.setRemainingTime(newRemainingTime)
                    displayPinLimitScreen()
                }
            }
        }
    }
    
    private func openResetVerify(with value: NumpadKey) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            open(.choosePassword(mode: .resetVerify(password), flow: nil, route: nil), by: .push)
        }
    }
    
    private func verifyResettedPassword(with value: NumpadKey, and previousPassword: String) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            if password != previousPassword {
                displaySimpleAlertWith(title: "password-verify-fail-title".localized, message: "password-verify-fail-message".localized)
                self.viewModel.reset(choosePasswordView)
                return
            }
            configuration.session?.savePassword(password)
            dismissScreen()
        }
    }
    
    private func confirmPassword(with value: NumpadKey) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            dismissScreen()
            if session?.isPasswordMatching(with: password) ?? false {
                delegate?.choosePasswordViewController(self, didConfirmPassword: true)
            } else {
                delegate?.choosePasswordViewController(self, didConfirmPassword: false)
            }
        }
    }
    
    private func deletePassword(with value: NumpadKey) {
        viewModel.configureSelection(in: choosePasswordView, for: value) { password in
            if session?.isPasswordMatching(with: password) ?? false {
                session?.deletePassword()
                dismissScreen()
            }
        }
    }
}

extension ChoosePasswordViewController: PinLimitViewControllerDelegate {
    func pinLimitViewControllerDidResetAllData(_ pinLimitViewController: PinLimitViewController) {
        UIApplication.shared.rootViewController()?.deleteAllData()
        open(.welcome(flow: .initializeAccount(mode: .none)), by: .launch, animated: false)
    }
}

extension ChoosePasswordViewController {
    enum Mode: Equatable {
        case setup
        case verify(String)
        case login
        case deletePassword
        case resetPassword
        case resetVerify(String)
        case confirm(String)
    }
}

protocol ChoosePasswordViewControllerDelegate: AnyObject {
    func choosePasswordViewController(_ choosePasswordViewController: ChoosePasswordViewController, didConfirmPassword isConfirmed: Bool)
}
