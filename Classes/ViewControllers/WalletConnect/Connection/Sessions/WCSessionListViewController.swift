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
//   WCSessionListViewController.swift

import UIKit

class WCSessionListViewController: BaseViewController {

    private lazy var sessionListView = WCSessionListView()

    private lazy var dataSource = WCSessionListDataSource(walletConnector: walletConnector)

    private lazy var layoutBuilder = WCSessionListLayout(dataSource: dataSource)

    override func configureAppearance() {
        view.backgroundColor = Colors.Background.tertiary
        title = "settings-wallet-connect-title".localized
    }

    override func linkInteractors() {
        super.linkInteractors()
        sessionListView.setDataSource(dataSource)
        sessionListView.setDelegate(layoutBuilder)
        dataSource.delegate = self
        walletConnector.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()
        prepareWholeScreenLayoutFor(sessionListView)
    }
}

extension WCSessionListViewController: WCSessionListDataSourceDelegate {
    func wSessionListDataSource(_ wSessionListDataSource: WCSessionListDataSource, didOpenDisconnectMenuFrom cell: WCSessionItemCell) {
        displayDisconnectionMenu(for: cell)
    }
}

extension WCSessionListViewController: WalletConnectorDelegate {
    func walletConnector(_ walletConnector: WalletConnector, didDisconnectFrom session: WalletConnectSession) {
        updateScreenAfterDisconnecting(from: session)
    }

    func walletConnector(_ walletConnector: WalletConnector, didFailWith error: WalletConnector.Error) {
        displayDisconnectionError(error)
    }
}

extension WCSessionListViewController {
    private func displayDisconnectionMenu(for cell: WCSessionItemCell) {
        guard let index = index(of: cell),
              let session = dataSource.session(at: index) else {
            return
        }

        let actionSheet = UIAlertController(
            title: nil,
            message: "wallet-connect-session-disconnect-message".localized(params: session.sessionDetail.dAppInfo.peerMeta.name),
            preferredStyle: .actionSheet
        )

        let disconnectAction = UIAlertAction(title: "title-disconnect".localized, style: .destructive) { _ in
            self.dataSource.disconnectFromSession(session)
        }

        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel)

        actionSheet.addAction(disconnectAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }

    private func index(of cell: WCSessionItemCell) -> Int? {
        return sessionListView.collectionView.indexPath(for: cell)?.item
    }

    private func updateScreenAfterDisconnecting(from session: WalletConnectSession) {
        guard let index = dataSource.index(of: session) else {
            sessionListView.collectionView.reloadData()
            return
        }

        sessionListView.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }

    private func displayDisconnectionError(_ error: WalletConnector.Error) {
        switch error {
        case let .failedToDisconnect(session):
            NotificationBanner.showError(
                "title-error".localized,
                message: "wallet-connect-session-disconnect-fail-message".localized(session.dAppInfo.peerMeta.name)
            )
        default:
            break
        }
    }
}
