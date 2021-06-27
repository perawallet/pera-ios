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
//   WCAssetAdditionTransactionViewModel.swift

import UIKit

class WCAssetAdditionTransactionViewModel {
    private(set) var senderInformationViewModel: TitledTransactionAccountNameViewModel?
    private(set) var assetInformationViewModel: TransactionAssetViewModel?
    private(set) var rekeyWarningInformationViewModel: WCTransactionAddressWarningInformationViewModel?
    private(set) var closeWarningInformationViewModel: WCTransactionAddressWarningInformationViewModel?
    private(set) var feeInformationViewModel: TitledTransactionAmountInformationViewModel?
    private(set) var noteInformationViewModel: WCTransactionTextInformationViewModel?
    private(set) var rawTransactionInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var algoExplorerInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var urlInformationViewModel: WCTransactionActionableInformationViewModel?
    private(set) var metadataInformationViewModel: WCTransactionActionableInformationViewModel?

    init(account: Account) {
        setSenderInformationViewModel(from: account)
        setAssetInformationViewModel()
        setRekeyWarningInformationViewModel(from: account)
        setCloseWarningInformationViewModel(from: account)
        setFeeInformationViewModel()
        setNoteInformationViewModel()
        setRawTransactionInformationViewModel()
        setAlgoExplorerInformationViewModel()
        setUrlInformationViewModel()
        setMetadataInformationViewModel()
    }

    private func setSenderInformationViewModel(from account: Account) {
        senderInformationViewModel = TitledTransactionAccountNameViewModel(title: "transaction-detail-from" .localized, account: account)
    }

    private func setAssetInformationViewModel() {
        assetInformationViewModel = TransactionAssetViewModel(assetDetail: nil, isLastElement: true)
    }

    private func setRekeyWarningInformationViewModel(from account: Account) {
        rekeyWarningInformationViewModel = WCTransactionAddressWarningInformationViewModel(
            account: account,
            warning: .rekeyed,
            isLastElement: false
        )
    }

    private func setCloseWarningInformationViewModel(from account: Account) {
        rekeyWarningInformationViewModel = WCTransactionAddressWarningInformationViewModel(
            account: account,
            warning: .closeAsset,
            isLastElement: true
        )
    }
    
    private func setFeeInformationViewModel() {
        feeInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-fee".localized,
            isLastElement: true
        )
    }

    private func setNoteInformationViewModel() {
        noteInformationViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(title: "transaction-detail-note".localized, detail: ""),
            isLastElement: false
        )
    }
    
    private func setRawTransactionInformationViewModel() {
        rawTransactionInformationViewModel = WCTransactionActionableInformationViewModel(information: .rawTransaction, isLastElement: false)
    }

    private func setAlgoExplorerInformationViewModel() {
        algoExplorerInformationViewModel = WCTransactionActionableInformationViewModel(information: .algoExplorer, isLastElement: false)
    }

    private func setUrlInformationViewModel() {
        urlInformationViewModel = WCTransactionActionableInformationViewModel(information: .assetUrl, isLastElement: false)
    }

    private func setMetadataInformationViewModel() {
        metadataInformationViewModel = WCTransactionActionableInformationViewModel(information: .assetMetadata, isLastElement: true)
    }
}
