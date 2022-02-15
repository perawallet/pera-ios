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
//   LedgerAccountVerificationViewController.swift

import UIKit

final class LedgerAccountVerificationViewController: BaseScrollViewController {
    private lazy var theme = Theme()
    private lazy var ledgerAccountVerificationView = LedgerAccountVerificationView()
    private lazy var verifyButton = Button()

    private lazy var ledgerAccountVerificationOperation = LedgerAccountVerifyOperation()
    private lazy var dataController = LedgerAccountVerificationDataController(accounts: selectedAccounts)

    private lazy var accountOrdering = AccountOrdering(
        sharedDataController: sharedDataController,
        session: session!
    )

    private var currentVerificationStatusView: LedgerAccountVerificationStatusView?
    private var currentVerificationAccount: Account?
    private var isVerificationCompleted = false {
        didSet {
            setAddButtonHidden(!isVerificationCompleted)
        }
    }

    private let accountSetupFlow: AccountSetupFlow
    private let selectedAccounts: [Account]

    init(
        accountSetupFlow: AccountSetupFlow,
        selectedAccounts: [Account],
        configuration: ViewControllerConfiguration
    ) {
        self.accountSetupFlow = accountSetupFlow
        self.selectedAccounts = selectedAccounts
        super.init(configuration: configuration)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startVerification()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ledgerAccountVerificationOperation.reset()
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        addVerificationAccountsToStack()
        setAddButtonHidden(true)
    }

    override func setListeners() {
        super.setListeners()
        verifyButton.addTarget(self, action: #selector(addVerifiedAccounts), for: .touchUpInside)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addLedgerAccountVerificationView(theme)
        addVerifyButton(theme)
    }
}

extension LedgerAccountVerificationViewController {
    private func addLedgerAccountVerificationView(_ theme: Theme) {
        ledgerAccountVerificationView.customize(theme.ledgerAccountVerificationViewTheme)

        contentView.addSubview(ledgerAccountVerificationView)
        ledgerAccountVerificationView.pinToSuperview()
    }

    private func addVerifyButton(_ theme: Theme) {
        verifyButton.customize(theme.verifyButtonTheme)
        verifyButton.bindData(ButtonCommonViewModel(title: "ledger-verified-add".localized))

        view.addSubview(verifyButton)
        verifyButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.bottom.equalToSuperview().inset(view.safeAreaBottom + theme.bottomInset)
        }
    }
}

extension LedgerAccountVerificationViewController {
    private func addVerificationAccountsToStack() {
        dataController.displayedVerificationAccounts.forEach { account in
            let statusView = LedgerAccountVerificationStatusView()
            statusView.customize(LedgerAccountVerificationStatusViewTheme())
            let viewModel = LedgerAccountVerificationStatusViewModel(
                account: account,
                status: ledgerAccountVerificationView.isStackViewEmpty ? .awaiting : .pending
            )
            statusView.bindData(viewModel)

            if ledgerAccountVerificationView.isStackViewEmpty {
                currentVerificationStatusView = statusView
            }

            ledgerAccountVerificationView.addArrangedSubview(statusView)
        }
    }

    private func startVerification() {
        guard let account = dataController.displayedVerificationAccounts.first else {
            return
        }

        currentVerificationAccount = account
        setVerificationLedgerDetail(for: account)
        ledgerAccountVerificationOperation.delegate = self
    }

    private func setAddButtonHidden(_ isHidden: Bool) {
        verifyButton.isHidden = isHidden
    }
}

extension LedgerAccountVerificationViewController {
    @objc
    private func addVerifiedAccounts() {
        saveVerifiedAccounts()

        let controller = open(
            .tutorial(flow: .none, tutorial: .ledgerSuccessfullyConnected),
            by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
        ) as? TutorialViewController
        controller?.uiHandlers.didTapButtonPrimaryActionButton = { _ in
            self.launchHome()
        }
    }

    private func saveVerifiedAccounts() {
        dataController.getVerifiedAccounts().forEach { account in
            if let localAccount = api?.session.accountInformation(from: account.address) {
                updateLocalAccount(localAccount, with: account)
            } else {
                setupLocalAccount(from: account)
            }
        }
    }

    private func updateLocalAccount(_ localAccount: AccountInformation, with account: Account) {
        var localAccount = localAccount
        localAccount.type = account.type
        setupLedgerDetails(of: &localAccount, from: account)

        api?.session.authenticatedUser?.updateAccount(localAccount)
    }

    private func setupLocalAccount(from account: Account) {
        var localAccount = AccountInformation(
            address: account.address,
            name: account.address.shortAddressDisplay(),
            type: account.type,
            preferredOrder: accountOrdering.getNewAccountIndex(for: account.type)
        )
        setupLedgerDetails(of: &localAccount, from: account)

        let user: User

        if let authenticatedUser = api?.session.authenticatedUser {
            user = authenticatedUser
            user.addAccount(localAccount)
        } else {
            user = User(accounts: [localAccount])
        }

        NotificationCenter.default.post(
            name: .didAddAccount,
            object: self
        )

        api?.session.authenticatedUser = user
    }

    private func setupLedgerDetails(of localAccount: inout AccountInformation, from account: Account) {
        if let authAddress = account.authAddress,
           let rekeyDetail = account.rekeyDetail {
            UIApplication.shared.firebaseAnalytics?.log(RegistrationEvent(type: .rekeyed))
            localAccount.addRekeyDetail(rekeyDetail, for: authAddress)
        } else {
            UIApplication.shared.firebaseAnalytics?.log(RegistrationEvent(type: .ledger))
            localAccount.ledgerDetail = account.ledgerDetail
        }
    }

    private func launchHome() {
        switch self.accountSetupFlow {
        case .initializeAccount:
            launchMain()
        case .addNewAccount:
            closeScreen(by: .dismiss, animated: true)
        case .none:
            break
        }
    }
}

extension LedgerAccountVerificationViewController: LedgerAccountVerifyOperationDelegate {
    func ledgerAccountVerifyOperation(_ ledgerAccountVerifyOperation: LedgerAccountVerifyOperation, didVerify account: String) {
        updateCurrentVerificationStatusView(with: .verified)
        dataController.addVerifiedAccount(currentVerificationAccount?.address)

        if dataController.isLastAccount(currentVerificationAccount) {
            isVerificationCompleted = true
            return
        }

        updatCurrentVerificationStates()
        verifyNextAccountIfExist()
    }

    func ledgerAccountVerifyOperationDidFinishTimingOperation(_ ledgerAccountVerifyOperation: LedgerAccountVerifyOperation) {
        
    }

    func ledgerAccountVerifyOperation(_ ledgerAccountVerifyOperation: LedgerAccountVerifyOperation, didFailed error: LedgerOperationError) {
        switch error {
        case .failedToFetchAddress:
            bannerController?.presentErrorBanner(
                 title: "ble-error-transmission-title".localized,
                 message: "ble-error-fail-fetch-account-address".localized
             )
            return
        case .cancelled:
            break
        case let .custom(title, message):
            bannerController?.presentErrorBanner(
                title: title,
                message: message
            )
        case .ledgerConnectionWarning:
            let warningModalTransition = BottomSheetTransition(presentingViewController: self)

             let warningAlert = WarningAlert(
                 title: "ledger-pairing-issue-error-title".localized,
                 image: img("img-warning-circle"),
                 description: "ble-error-fail-ble-connection-repairing".localized,
                 actionTitle: "title-ok".localized
             )

             warningModalTransition.perform(
                 .warningAlert(warningAlert: warningAlert),
                 by: .presentWithoutNavigationController
             )
        default:
            bannerController?.presentErrorBanner(
                title: "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
            return
        }

        updateCurrentVerificationStatusView(with: .unverified)

        if dataController.isLastAccount(currentVerificationAccount) {
            isVerificationCompleted = true
            return
        }

        updatCurrentVerificationStates()
        verifyNextAccountIfExist()
    }

    private func updateCurrentVerificationStatusView(with status: LedgerVerificationStatus) {
        if let account = currentVerificationAccount {
            currentVerificationStatusView?.bindData(LedgerAccountVerificationStatusViewModel(account: account, status: status))
        }
    }

    private func updatCurrentVerificationStates() {
        guard let currentVerificationAccount = currentVerificationAccount,
              let currentVerificationStatusView = currentVerificationStatusView,
              let nextVerificationIndex = dataController.nextIndexForVerification(from: currentVerificationAccount.address),
              let nextVerificationAccount = dataController.displayedVerificationAccounts[safe: nextVerificationIndex],
              let nextVerificationStatusView = ledgerAccountVerificationView.statusViews.nextView(
                of: currentVerificationStatusView
              ) as? LedgerAccountVerificationStatusView else {
            return
        }

        self.currentVerificationAccount = nextVerificationAccount
        self.currentVerificationStatusView = nextVerificationStatusView
    }

    private func verifyNextAccountIfExist() {
        guard let currentVerificationAccount = currentVerificationAccount,
              let currentVerificationStatusView = currentVerificationStatusView else {
            return
        }
        
        currentVerificationStatusView.bindData(
            LedgerAccountVerificationStatusViewModel(account: currentVerificationAccount, status: .awaiting)
        )
        setVerificationLedgerDetail(for: currentVerificationAccount)
        ledgerAccountVerificationOperation.startOperation()
    }

    private func setVerificationLedgerDetail(for account: Account) {
        if let authAddress = account.authAddress {
            if let rekeyedLedgerDetail = account.rekeyDetail?[authAddress] {
                // If the auth account of rekeyed account is not one of the selected accounts, use the ledger index of the account
                if let ledgerDetail = account.ledgerDetail,
                   rekeyedLedgerDetail.id != ledgerDetail.id {
                    ledgerAccountVerificationOperation.setLedgerDetail(account.ledgerDetail)
                    return
                }
            } else {
                ledgerAccountVerificationOperation.setLedgerDetail(account.ledgerDetail)
                return
            }
        }

        ledgerAccountVerificationOperation.setLedgerDetail(account.currentLedgerDetail)
    }
}

enum LedgerVerificationStatus {
    case awaiting
    case pending
    case verified
    case unverified
}
