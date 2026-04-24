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

//   InboxDiffableDataSource.swift

import SwiftUI
import UIKit
import pera_wallet_core
import SwiftUI

final class InboxDiffableDataSource: UICollectionViewDiffableDataSource<Int, InboxViewModel.RowType> {
    
    init(collectionView: UICollectionView, onJointAccountInviteInboxRowTap: ((InboxRowIdentifier) -> Void)?) {
        
        super.init(collectionView: collectionView) { collectionView, indexPath, rowType in
            switch rowType {
            case let .jointAccountImport(model):
                let cell = collectionView.dequeue(JointAccountInviteInboxCell.self, at: indexPath)
                let identifier: InboxRowIdentifier = .import(uniqueIdentifier: model.id)
                cell.identifier = identifier
                cell.update(isDotVisible: model.isUnread, message: model.title, timestamp: model.timestamp, onDetailsButtonTap: { onJointAccountInviteInboxRowTap?(identifier) })
                return cell
            case let .jointAccountSend(model):
                let cell = collectionView.dequeue(JointAccountSendRequestInboxCell.self, at: indexPath)
                cell.identifier = .sendRequest(uniqueIdentifier: model.id)
                cell.update(isDotVisible: model.isUnread, message: model.title, stateViewModel: model.state.viewModel, creationDatetime: model.creationDatetime, signedTransactionsText: model.signedTransactionsText, deadline: model.deadline)
                return cell
            case let .asset(model):
                let cell = collectionView.dequeue(IncomingASAAccountCell.self, at: indexPath)
                cell.identifier = .asset(uniqueIdentifier: model.id)
                cell.update(icon: model.icon, title: model.title, primaryAccessory: model.primaryAccesory)
                return cell
            }
        }
        
        [JointAccountInviteInboxCell.self, JointAccountSendRequestInboxCell.self, IncomingASAAccountCell.self]
            .forEach(collectionView.register)
    }
}

private extension InboxViewModel.SignRequestState {

    var viewModel: JointAccountSendRequestInboxRow.StateViewModel {
        switch self {
        case .pending:
            return JointAccountSendRequestInboxRow.StateViewModel(text: "inbox.joint-account-send-request.state.pending", icon: .Icons.hourglass, tint: .Global.Yellow._600)
        case .submitting:
            return JointAccountSendRequestInboxRow.StateViewModel(text: "inbox.joint-account-send-request.state.submitting", icon: .Icons.hourglass, tint: .Global.Yellow._600)
        case .confirmed:
            return JointAccountSendRequestInboxRow.StateViewModel(text: "inbox.joint-account-send-request.state.confirmed", icon: .Icons.check, tint: .Helpers.positive)
        case let .failed(reason):
            let text: LocalizedStringKey
            if let trimmed = reason?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty {
                text = LocalizedStringKey(trimmed)
            } else {
                text = "inbox.joint-account-send-request.state.failed"
            }
            return JointAccountSendRequestInboxRow.StateViewModel(text: text, icon: .Icons.error, tint: .Helpers.negative)
        case .expired:
            return JointAccountSendRequestInboxRow.StateViewModel(text: "inbox.joint-account-send-request.state.expired", icon: .Icons.error, tint: .Helpers.negative)
        case .declined:
            return JointAccountSendRequestInboxRow.StateViewModel(text: "inbox.joint-account-send-request.state.declined", icon: .Icons.error, tint: .Helpers.negative)
        }
    }
}
