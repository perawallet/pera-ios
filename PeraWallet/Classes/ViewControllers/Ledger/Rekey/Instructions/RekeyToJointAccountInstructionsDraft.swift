// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RekeyToJointAccountInstructionsDraft.swift

import pera_wallet_core

final class RekeyToJointAccountInstructionsDraft: RekeyInstructionsDraft {

    // MARK: - Initialisers
    
    init(sourceAccount: Account) {
        
        let title = String(localized: "title-rekey-with-shared-account").titleMedium()
        let body = Self.makeBody(text: String(localized: "rekey-shared-to-shared-account-instructions-body"), highlightedText: String(localized: "title-learn-more"))
        
        let instructions: [InstructionItemViewModel] = [
            RekeyStandardToStandardAccountFutureTransactionsSignInstructionViewModel(order: 1),
            RekeyAnyAccountToAnyAccountNoConfigurationChangeInstructionViewModel(order: 2)
        ]
        
        super.init(image: "rekey-from-rekeyed-account-illustration", title: title, body: body, instructions: instructions)
    }
}
