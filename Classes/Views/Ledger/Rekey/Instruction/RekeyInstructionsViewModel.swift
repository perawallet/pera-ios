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
//   RekeyInstructionsViewModel.swift

import Macaroon

final class RekeyInstructionsViewModel {
    private(set) var subtitle: String?
    private(set) var firstInstructionViewTitle: String?
    private(set) var secondInstructionViewTitle: String?
    private(set) var thirdInstructionViewTitle: String?

    init(_ requiresLedgerConnection: Bool) {
        bindSubtitle(requiresLedgerConnection)
        bindFirstInstructionViewTitle()
        bindSecondInstructionViewTitle(requiresLedgerConnection)
        bindThirdInstructionViewTitle()
    }
}

extension RekeyInstructionsViewModel {
    private func bindSubtitle(_ requiresLedgerConnection: Bool) {
        if requiresLedgerConnection {
            subtitle = "rekey-instruction-subtitle-ledger".localized
        } else {
            subtitle = "rekey-instruction-second-ledger".localized
        }
    }
    
    private func bindFirstInstructionViewTitle() {
        firstInstructionViewTitle = "rekey-instruction-first".localized
    }

    private func bindSecondInstructionViewTitle(_ requiresLedgerConnection: Bool) {
        if requiresLedgerConnection {
            secondInstructionViewTitle = "rekey-instruction-second-ledger".localized
        } else {
            secondInstructionViewTitle = "rekey-instruction-second-standard".localized
        }
    }

    private func bindThirdInstructionViewTitle() {
        thirdInstructionViewTitle = "rekey-instruction-third".localized
    }
}
