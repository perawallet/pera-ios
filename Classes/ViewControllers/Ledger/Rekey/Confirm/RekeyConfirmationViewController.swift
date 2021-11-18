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
//  RekeyConfirmationViewController.swift

import UIKit
import MagpieHipo
import MacaroonUtils

final class RekeyConfirmationViewController: BaseViewController {
    private lazy var rekeyConfirmationView = RekeyConfirmationView()

    private var account: Account
    private let ledger: LedgerDetail?
    private let ledgerAddress: String
    
    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api, bannerController: bannerController)
    }()
    
    init(account: Account, ledger: LedgerDetail?, ledgerAddress: String, configuration: ViewControllerConfiguration) {
        self.account = account
        self.ledger = ledger
        self.ledgerAddress = ledgerAddress
        super.init(configuration: configuration)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rekeyConfirmationView.startAnimatingImageView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rekeyConfirmationView.stopAnimatingImageView()
    }
    
    override func linkInteractors() {
        rekeyConfirmationView.delegate = self
        transactionController.delegate = self
    }

    override func setListeners() {
        rekeyConfirmationView.setListeners()
    }

    override func bindData() {
        rekeyConfirmationView.bindData(RekeyConfirmationViewModel(account: account, ledgerName: ledger?.name))
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        rekeyConfirmationView.customize(RekeyConfirmationViewTheme())
        view.addSubview(rekeyConfirmationView)
        rekeyConfirmationView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension RekeyConfirmationViewController: RekeyConfirmationViewDelegate {
    func rekeyConfirmationViewDidFinalizeConfirmation(_ rekeyConfirmationView: RekeyConfirmationView) {
        guard let session = session,
              session.canSignTransaction(for: &account) else {
                  return
              }
        
        let rekeyTransactionDraft = RekeyTransactionSendDraft(account: account, rekeyedTo: ledgerAddress)
        transactionController.setTransactionDraft(rekeyTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .rekey)
        
        if account.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}

extension RekeyConfirmationViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: TransactionSendDraft?) {
        log(RekeyEvent())
        saveRekeyedAccountDetails()
        openRekeyConfirmationAlert()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPTransactionError) {
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.asAFError?.errorDescription ?? error.localizedDescription
            )
        }
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPTransactionError) {
        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: "title-error".localized, message: error.debugDescription)
        }
    }
}

extension RekeyConfirmationViewController {
    private func saveRekeyedAccountDetails() {
        if let localAccount = session?.accountInformation(from: account.address),
           let ledgerDetail = ledger {
            localAccount.type = .rekeyed
            account.type = .rekeyed
            localAccount.addRekeyDetail(ledgerDetail, for: ledgerAddress)

            session?.authenticatedUser?.updateAccount(localAccount)
            session?.updateAccount(account)
        }
    }

    private func openRekeyConfirmationAlert() {
        let controller = open(
            .tutorial(flow: .none, tutorial: .accountSuccessfullyRekeyed(accountName: account.name.ifNil(.empty))),
            by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
        ) as? TutorialViewController
        controller?.uiHandlers.didTapButtonPrimaryActionButton = { _ in
            self.dismissScreen()
        }
    }
    
    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "send-algos-minimum-amount-custom-error".localized(params: amount.toAlgos.toAlgosStringForLabel ?? ""
                )
            )
        case .invalidAddress:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
        case let .sdkError(error):
            bannerController?.presentErrorBanner(
                title: "title-error".localized, message: error.debugDescription
            )
        default:
            break
        }
    }
}
