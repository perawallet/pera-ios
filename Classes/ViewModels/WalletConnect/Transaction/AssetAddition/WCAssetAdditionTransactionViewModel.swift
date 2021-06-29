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

    init(transactionParams: WCTransactionParams, senderAccount: Account, assetDetail: AssetDetail) {
        setSenderInformationViewModel(from: senderAccount)
        setAssetInformationViewModel(from: transactionParams, and: assetDetail)
        setCloseWarningInformationViewModel(from: transactionParams)
        setRekeyWarningInformationViewModel(from: transactionParams)
        setFeeInformationViewModel(from: transactionParams)
        setNoteInformationViewModel(from: transactionParams)
        setRawTransactionInformationViewModel(from: transactionParams)
        setAlgoExplorerInformationViewModel()
        setUrlInformationViewModel()
        setMetadataInformationViewModel()
    }

    private func setSenderInformationViewModel(from senderAccount: Account) {
        senderInformationViewModel = TitledTransactionAccountNameViewModel(
            title: "transaction-detail-from" .localized,
            account: senderAccount
        )
    }

    private func setAssetInformationViewModel(from transactionParam: WCTransactionParams, and assetDetail: AssetDetail) {
        guard let transaction = transactionParam.transaction else {
            return
        }

        assetInformationViewModel = TransactionAssetViewModel(
            assetDetail: assetDetail,
            isLastElement: !transaction.isRekeyTransaction && !transaction.isCloseTransaction
        )
    }

    private func setCloseWarningInformationViewModel(from transactionParam: WCTransactionParams) {
        guard let transaction = transactionParam.transaction,
              let closeAddress = transaction.closeAddress else {
            return
        }

        closeWarningInformationViewModel = WCTransactionAddressWarningInformationViewModel(
            address: closeAddress,
            warning: .closeAlgos,
            isLastElement: !transaction.isRekeyTransaction
        )
    }

    private func setRekeyWarningInformationViewModel(from transactionParam: WCTransactionParams) {
        guard let rekeyAddress = transactionParam.transaction?.rekeyAddress else {
            return
        }

        rekeyWarningInformationViewModel = WCTransactionAddressWarningInformationViewModel(
            address: rekeyAddress,
            warning: .rekeyed,
            isLastElement: true
        )
    }
    
    private func setFeeInformationViewModel(from transactionParams: WCTransactionParams) {
        guard let fee = transactionParams.transaction?.fee else {
            return
        }

        feeInformationViewModel = TitledTransactionAmountInformationViewModel(
            title: "transaction-detail-fee".localized,
            mode: .fee(value: fee),
            isLastElement: true
        )
    }

    private func setNoteInformationViewModel(from transactionParams: WCTransactionParams) {
        guard let note = transactionParams.transaction?.noteRepresentation() else {
            return
        }

        noteInformationViewModel = WCTransactionTextInformationViewModel(
            information: TitledInformation(title: "transaction-detail-note".localized, detail: note),
            isLastElement: false
        )
    }
    
    private func setRawTransactionInformationViewModel(from transactionParams: WCTransactionParams) {
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
