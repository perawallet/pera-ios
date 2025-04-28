// Copyright 2022-2025 Pera Wallet, LDA

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
//  TutorialViewModel.swift

import UIKit
import MacaroonUIKit
import Foundation

final class TutorialViewModel: ViewModel {
    private(set) var image: UIImage?
    private(set) var title: String?
    private(set) var description: String?
    private(set) var primaryActionButtonTitle: String?
    private(set) var secondaryActionButtonTitle: String?
    private(set) var warningDescription: String?
    
    private(set) var primaryActionButtonTheme: ButtonTheme?
    private(set) var secondaryActionButtonTheme: ButtonTheme?

    init(_ model: Tutorial, theme: TutorialViewTheme) {
        bindImage(model)
        bindTitle(model)
        bindDescription(model)
        bindPrimaryActionButtonTitle(model)
        bindSecondaryActionButtonTitle(model)
        bindWarningTitle(model)
        bindButtonsStyle(model, theme: theme)
    }
}

extension TutorialViewModel {
    private func bindImage(_ tutorial: Tutorial) {
        switch tutorial {
        case .backUp:
            image = img("shield")
        case .recoverWithPassphrase:
            image = img("key")
        case .watchAccount:
            image = img("eye")
        case .writePassphrase:
            image = img("pen")
        case .passcode:
            image = img("locked")
        case .localAuthentication:
            image = img("faceid")
        case .biometricAuthenticationEnabled, .accountVerified, .ledgerSuccessfullyConnected:
            image = img("check")
        case .failedToImportLedgerAccounts:
            image = img("icon-error-close")
        case .passphraseVerified:
            image = img("shield-check")
        case .recoverWithLedger:
            image = img("ledger")
        case .collectibleTransferConfirmed:
            image = img("check")
        }
    }

    private func bindTitle(_ tutorial: Tutorial) {
        switch tutorial {
        case .backUp:
            title = String(localized: "tutorial-title-back-up")
        case .recoverWithPassphrase:
            title = String(localized: "tutorial-title-recover")
        case .watchAccount:
            title = String(localized: "title-watch-account").capitalized
        case .writePassphrase:
            title = String(localized: "tutorial-title-write")
        case .passcode:
            title = String(localized: "tutorial-title-passcode")
        case .localAuthentication:
            title = String(localized: "local-authentication-preference-title")
        case .biometricAuthenticationEnabled:
            title = String(localized: "local-authentication-enabled-title")
        case .passphraseVerified:
            title = String(localized: "pass-phrase-verify-pop-up-title")
        case .accountVerified(let flow, _):
            bindAccountSetupFlowTitle(flow)
        case .recoverWithLedger:
            title = String(localized: "ledger-tutorial-title-text")
        case .ledgerSuccessfullyConnected:
            title = String(localized: "recover-from-seed-verify-pop-up-title")
        case .failedToImportLedgerAccounts:
            title = String(localized: "tutorial-title-failed-to-import-ledger-accounts")
        case .collectibleTransferConfirmed:
            title = String(localized: "collectible-transfer-confirmed-title")
        }
    }

    private func bindDescription(_ tutorial: Tutorial) {
        switch tutorial {
        case .backUp:
            description = String(localized: "tutorial-description-back-up")
        case .recoverWithPassphrase:
            description = String(localized: "tutorial-description-recover")
        case .watchAccount:
            description = String(localized: "tutorial-description-watch")
        case .writePassphrase:
            description = String(localized: "tutorial-description-write")
        case .passcode:
            description = String(localized: "tutorial-description-passcode")
        case .localAuthentication:
            description = String(localized: "tutorial-description-local")
        case .biometricAuthenticationEnabled:
            description = String(localized: "local-authentication-enabled-subtitle")
        case .passphraseVerified:
            description = String(localized: "pass-phrase-verify-pop-up-explanation")
        case .accountVerified(let flow, _):
            bindAccountSetupFlowDescription(flow)
        case .recoverWithLedger:
            description = String(localized: "tutorial-description-ledger")
        case .ledgerSuccessfullyConnected(let flow):
            bindAccountSetupFlowDescription(flow)
        case .failedToImportLedgerAccounts:
            description = String(localized: "tutorial-description-failed-to-import-ledger-accounts")
        case .collectibleTransferConfirmed:
            description = String(localized: "collectible-transfer-confirmed-description")
        }
    }

    private func bindPrimaryActionButtonTitle(_ tutorial: Tutorial) {
        switch tutorial {
        case .backUp:
            primaryActionButtonTitle = String(localized: "title-i-understand")
        case .recoverWithPassphrase:
            primaryActionButtonTitle = String(localized: "tutorial-main-title-recover")
        case .watchAccount:
            primaryActionButtonTitle = String(localized: "watch-account-button")
        case .writePassphrase:
            primaryActionButtonTitle = String(localized: "tutorial-main-title-write")
        case .passcode:
            primaryActionButtonTitle = String(localized: "tutorial-main-title-passcode")
        case .localAuthentication:
            primaryActionButtonTitle = String(localized: "local-authentication-enable")
        case .biometricAuthenticationEnabled:
            primaryActionButtonTitle = String(localized: "title-go-to-accounts")
        case .passphraseVerified:
            primaryActionButtonTitle = String(localized: "title-next")
        case .accountVerified(let flow, _):
            bindAccountSetupFlowPrimaryButton(flow)
        case .recoverWithLedger:
            primaryActionButtonTitle = String(localized: "ledger-tutorial-title-text")
        case .ledgerSuccessfullyConnected(let flow):
            bindAccountSetupFlowPrimaryButton(flow)
        case .failedToImportLedgerAccounts:
            primaryActionButtonTitle = String(localized: "tutorial-main-title-ledger-connected")
        case .collectibleTransferConfirmed:
            primaryActionButtonTitle = String(localized: "collectible-transfer-confirmed-action-title")
        }
    }

    private func bindWarningTitle(_ tutorial: Tutorial) {
        switch tutorial {
        case .watchAccount:
            warningDescription = String(localized: "tutorial-description-watch-warning")
        case .writePassphrase:
            warningDescription = String(localized: "tutorial-description-write-warning")
        default:
            break
        }
    }

    private func bindSecondaryActionButtonTitle(_ tutorial: Tutorial) {
        switch tutorial {
        case .passcode:
            secondaryActionButtonTitle = String(localized: "tutorial-action-title-passcode")
        case .localAuthentication:
            secondaryActionButtonTitle = String(localized: "local-authentication-no")
        case .recoverWithLedger:
            secondaryActionButtonTitle = String(localized: "tutorial-action-title-ledger")
        case .backUp(let flow, _),
             .writePassphrase(let flow, _):
            guard !flow.isBackUpAccount else { return }

            secondaryActionButtonTitle = String(localized: "title-skip-for-now")
        case .accountVerified(let flow, _):
            bindAccountSetupFlowSecondaryButton(flow)
        case .ledgerSuccessfullyConnected(let flow):
            bindAccountSetupFlowSecondaryButton(flow)
        default:
            break
        }
    }
}

extension TutorialViewModel {
    private func bindAccountSetupFlowTitle(_ flow: AccountSetupFlow) {
        self.title = String(localized: "recover-from-seed-verify-pop-up-title")
    }
    
    private func bindAccountSetupFlowDescription(_ flow: AccountSetupFlow) {
        if case .initializeAccount(mode: .watch) = flow {
            self.description = String(localized: "recover-from-seed-verify-pop-up-description-watch-account-initialize")
        } else if case .addNewAccount(mode: .watch) = flow {
            self.description = String(localized: "recover-from-seed-verify-pop-up-description-watch-account-add")
        } else {
            switch flow {
            case .initializeAccount:
                self.description = String(localized: "recover-from-seed-verify-pop-up-explanation")
            case .addNewAccount,
                 .backUpAccount,
                 .none:
                self.description = String(localized: "recover-from-seed-verify-pop-up-explanation-already-added")
            }
        }
    }
    
    private func bindAccountSetupFlowPrimaryButton(_ flow: AccountSetupFlow) {
        if case .initializeAccount(mode: .watch) = flow {
            self.primaryActionButtonTitle = String(localized: "title-start-using-pera-wallet")
        } else if case .addNewAccount(mode: .watch) = flow {
            self.primaryActionButtonTitle = String(localized: "title-continue")
        } else {
            self.primaryActionButtonTitle = String(localized: "quick-actions-buy-algo-title")
        }
    }

    private func bindAccountSetupFlowSecondaryButton(_ flow: AccountSetupFlow) {
        if case .initializeAccount(mode: .watch) = flow {
            self.secondaryActionButtonTitle = nil
        } else if case .addNewAccount(mode: .watch) = flow {
            self.secondaryActionButtonTitle = nil
        } else {
            switch flow {
            case .initializeAccount:
                self.secondaryActionButtonTitle = String(localized: "title-start-using-pera-wallet")
            case .addNewAccount,
                 .backUpAccount,
                 .none:
                self.secondaryActionButtonTitle = String(localized: "title-continue")
            }
        }
    }

    private func bindButtonsStyle(_ tutorial: Tutorial, theme: TutorialViewTheme) {
        switch tutorial {
        case .accountVerified(let flow, _):
            bindAccountSetupFlowButtonsTheme(flow, theme: theme)
        case .ledgerSuccessfullyConnected(let flow):
            bindAccountSetupFlowButtonsTheme(flow, theme: theme)
        default:
            return
        }
    }
    
    private func bindAccountSetupFlowButtonsTheme(_ flow: AccountSetupFlow, theme: TutorialViewTheme) {
        if case .initializeAccount(mode: .watch) = flow {
            return
        } else if case .addNewAccount(mode: .watch) = flow {
            return
        } else {
            self.primaryActionButtonTheme = theme.actionButtonTheme
            self.secondaryActionButtonTheme = theme.mainButtonTheme
        }
    }
}
