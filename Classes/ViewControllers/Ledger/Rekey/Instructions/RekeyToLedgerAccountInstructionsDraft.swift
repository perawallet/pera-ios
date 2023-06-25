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

//   RekeyToLedgerAccountInstructionsDraft.swift

import Foundation
import MacaroonUIKit

final class RekeyToLedgerAccountInstructionsDraft: RekeyInstructionsDraft {
    init(sourceAccount: Account) {
        let image = Self.makeImage(
            sourceAccount: sourceAccount
        )
        let title = Self.makeTitle(
            sourceAccount: sourceAccount
        )
        let body = Self.makeBody(
            sourceAccount: sourceAccount
        )
        let instructions = Self.makeInstructions(
            sourceAccount: sourceAccount
        )

        super.init(
            image: image,
            title: title,
            body: body,
            instructions: instructions
        )
    }
}

extension RekeyToLedgerAccountInstructionsDraft {
    private static func makeImage(
        sourceAccount: Account
    ) -> Image {
        switch sourceAccount.type {
        case .standard: return "rekey-from-standard-account-illustration"
        case .ledger: return "rekey-from-ledger-account-illustration"
        case .rekeyed: return "rekey-from-rekeyed-account-illustration"
        case .watch: preconditionFailure("Watch account case is not possible")
        }
    }
}

extension RekeyToLedgerAccountInstructionsDraft {
    private static func makeTitle(
        sourceAccount: Account
    ) -> TextProvider {
        return "title-rekey-to-ledger-account-capitalized-sentence"
            .localized
            .titleMedium()
    }
}

extension RekeyToLedgerAccountInstructionsDraft {
    private static func makeBody(
        sourceAccount: Account
    ) -> RekeyInstructionsBodyTextProvider {
        switch sourceAccount.type {
        case .standard: return Self.makeRekeyStandardAccountToLedgerAccountBody()
        case .ledger: return Self.makeRekeyLedgerAccountToLedgerAccountInstructions()
        case .rekeyed: return Self.makeRekeyRekeyedAccountToLedgerAccountInstructions()
        case .watch: preconditionFailure("Watch account case is not possible")
        }
    }

    private static func makeRekeyStandardAccountToLedgerAccountBody() -> RekeyInstructionsBodyTextProvider {
        let text = "rekey-standard-to-ledger-account-instructions-body".localized
        let highlightedText = "rekey-standard-to-ledger-account-instructions-body-highlighted-text".localized
        return Self.makeBody(text: text, highlightedText: highlightedText)
    }

    private static func makeRekeyLedgerAccountToLedgerAccountInstructions() -> RekeyInstructionsBodyTextProvider {
        let text = "rekey-ledger-to-ledger-account-instructions-body".localized
        let highlightedText = "rekey-ledger-to-ledger-account-instructions-body-highlighted-text".localized
        return Self.makeBody(text: text, highlightedText: highlightedText)
    }

    private static func makeRekeyRekeyedAccountToLedgerAccountInstructions() -> RekeyInstructionsBodyTextProvider {
        let text = "rekey-rekeyed-to-ledger-account-instructions-body".localized
        let highlightedText = "rekey-rekeyed-to-ledger-account-instructions-body-highlighted-text".localized
        return Self.makeBody(text: text, highlightedText: highlightedText)
    }
}

extension RekeyToLedgerAccountInstructionsDraft {
    private static func makeInstructions(
        sourceAccount: Account
    ) -> [InstructionItemViewModel] {
        switch sourceAccount.type {
        case .standard: return Self.makeRekeyStandardAccountToLedgerAccountInstructions()
        case .ledger: return Self.makeRekeyLedgerAccountToLedgerAccountInstructions()
        case .rekeyed: return Self.makeRekeyRekeyedAccountToLedgerAccountInstructions()
        case .watch: preconditionFailure("Watch account case is not possible")
        }
    }

    private static func makeRekeyStandardAccountToLedgerAccountInstructions() -> [InstructionItemViewModel] {
        return [
            RekeyAnyAccountToLedgerAccountFutureTransactionsSignInstructionViewModel(order: 1),
            RekeyAnyAccountToAnyAccountNoLongerAbleToSignInstructionViewModel(order: 2),
            RekeyAnyAccountToAnyAccountNoConfigurationChangeInstructionViewModel(order: 3),
            RekeyAnyAccountToAnyAccountOpenBluetoothInstructionViewModel(order: 4)
        ]
    }

    private static func makeRekeyLedgerAccountToLedgerAccountInstructions() -> [InstructionItemViewModel] {
        return [
            RekeyAnyAccountToLedgerAccountFutureTransactionsSignInstructionViewModel(order: 1),
            RekeyLedgerToLedgerAccountNoLongerConnectedInstructionViewModel(order: 2),
            RekeyAnyAccountToAnyAccountNoConfigurationChangeInstructionViewModel(order: 3),
            RekeyAnyAccountToAnyAccountOpenBluetoothInstructionViewModel(order: 4)
        ]
    }

    private static func makeRekeyRekeyedAccountToLedgerAccountInstructions() -> [InstructionItemViewModel] {
        return [
            RekeyRekeyedToLedgerAccountFutureTransactionsSignInstructionViewModel(order: 1),
            RekeyRekeyedToAnyAccountContinueUnableToSignInstructionViewModel(order: 2),
            RekeyAnyAccountToAnyAccountNoConfigurationChangeInstructionViewModel(order: 3),
            RekeyAnyAccountToAnyAccountOpenBluetoothInstructionViewModel(order: 4)
        ]
    }
}
