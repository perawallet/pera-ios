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
//   WCAssetTransactionView.swift

import UIKit

class WCAssetTransactionView: WCSingleTransactionView {

    weak var delegate: WCAssetTransactionViewDelegate?

    private lazy var accountInformationView = TitledTransactionAccountNameView()

    private lazy var assetInformationView = TransactionAssetView()

    private lazy var receiverInformationView = WCTransactionTextInformationView()

    private lazy var rekeyWarningInformationView = WCTransactionAddressWarningInformationView()

    private lazy var closeWarningInformationView = WCTransactionAddressWarningInformationView()

    private lazy var balanceInformationView = TitledTransactionAmountInformationView()

    private lazy var amountInformationView = TitledTransactionAmountInformationView()

    private lazy var feeInformationView = TitledTransactionAmountInformationView()

    private lazy var noteInformationView = WCTransactionTextInformationView()

    private lazy var rawTransactionInformationView = WCTransactionActionableInformationView()

    override func prepareLayout() {
        super.prepareLayout()
        addParticipantInformationViews()
        addBalanceInformationViews()
        addDetailedInformationViews()
    }

    override func setListeners() {
        rawTransactionInformationView.addTarget(self, action: #selector(notifyDelegateToOpenRawTransaction), for: .touchUpInside)
    }
}

extension WCAssetTransactionView {
    private func addParticipantInformationViews() {
        addParticipantInformationView(accountInformationView)
        addParticipantInformationView(assetInformationView)
        addParticipantInformationView(receiverInformationView)
        addParticipantInformationView(rekeyWarningInformationView)
        addParticipantInformationView(closeWarningInformationView)
    }

    private func addBalanceInformationViews() {
        addBalanceInformationView(balanceInformationView)
        addBalanceInformationView(amountInformationView)
        addBalanceInformationView(feeInformationView)
    }

    private func addDetailedInformationViews() {
        addDetailedInformationView(noteInformationView)
        addDetailedInformationView(rawTransactionInformationView)
    }
}

extension WCAssetTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcAssetTransactionViewDidOpenRawTransaction(self)
    }
}

extension WCAssetTransactionView {
    func bind(_ viewModel: WCAssetTransactionViewModel) {
        accountInformationView.bind(viewModel.senderInformationViewModel)

        if let assetInformationViewModel = viewModel.assetInformationViewModel {
            assetInformationView.bind(assetInformationViewModel)
        }

        if let receiverInformationViewModel = viewModel.receiverInformationViewModel {
            receiverInformationView.bind(receiverInformationViewModel)
        }

        if let rekeyWarningInformationViewModel = viewModel.rekeyWarningInformationViewModel {
            rekeyWarningInformationView.bind(rekeyWarningInformationViewModel)
        } else {
            hideViewInStack(rekeyWarningInformationView)
        }

        if let closeWarningInformationViewModel = viewModel.closeWarningInformationViewModel {
            closeWarningInformationView.bind(closeWarningInformationViewModel)
        } else {
            hideViewInStack(closeWarningInformationView)
        }

        balanceInformationView.bind(viewModel.balanceInformationViewModel)
        amountInformationView.bind(viewModel.amountInformationViewModel)
        feeInformationView.bind(viewModel.feeInformationViewModel)

        if let noteInformationViewModel = viewModel.noteInformationViewModel {
            noteInformationView.bind(noteInformationViewModel)
        } else {
            hideViewInStack(noteInformationView)
        }

        if let rawTransactionInformationViewModel = viewModel.rawTransactionInformationViewModel {
            rawTransactionInformationView.bind(rawTransactionInformationViewModel)
        }
    }

    private func hideViewInStack(_ view: UIView) {
        view.isHidden = true
    }
}

protocol WCAssetTransactionViewDelegate: AnyObject {
    func wcAssetTransactionViewDidOpenRawTransaction(_ wcAssetTransactionView: WCAssetTransactionView)
}
