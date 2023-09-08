// Copyright 2022 Pera Wallet, LDA

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
//   WCSessionShortListViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonUtils
import MacaroonBottomSheet

final class WCSessionShortListViewController:
    BaseViewController,
    PeraConnectObserver {
    weak var delegate: WCSessionShortListViewControllerDelegate?

    private lazy var theme = Theme()

    private(set) lazy var sessionListView = WCSessionShortListView()

    private lazy var dataSource = WCSessionShortListDataSource(walletConnectCoordinator: peraConnect.walletConnectCoordinator)
    private lazy var layoutBuilder = WCSessionShortListLayout(theme)

    override func viewDidLoad() {
        super.viewDidLoad()

        peraConnect.add(self)
    }

    override func linkInteractors() {
        super.linkInteractors()
        sessionListView.setCollectionViewDataSource(dataSource)
        sessionListView.setCollectionViewDelegate(layoutBuilder)
        dataSource.delegate = self
        sessionListView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()
        addSessionListView()
    }
}

extension WCSessionShortListViewController {
    private func addSessionListView() {
        view.addSubview(sessionListView)
        sessionListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension WCSessionShortListViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return theme.calculateModalHeightAsBottomSheet(self)
    }
}

extension WCSessionShortListViewController: WCSessionShortListViewDelegate {
    func wcSessionShortListViewDidTapCloseButton(_ wcSessionShortListView: WCSessionShortListView) {
        delegate?.wcSessionShortListViewControllerDidClose(self)
        dismissScreen()
    }
}

extension WCSessionShortListViewController: WCSessionShortListDataSourceDelegate {
    func wcSessionShortListDataSource(_ wSessionListDataSource: WCSessionShortListDataSource, didOpenDisconnectMenuFrom cell: WCSessionShortListItemCell) {
        displayDisconnectionMenu(for: cell)
    }
}

extension WCSessionShortListViewController {
    private func index(of cell: WCSessionShortListItemCell) -> Int? {
        return sessionListView.collectionView.indexPath(for: cell)?.item
    }
}

extension WCSessionShortListViewController {
    private func displayDisconnectionMenu(for cell: WCSessionShortListItemCell) {
        guard let index = index(of: cell),
              let session = dataSource.session(at: index) else {
            return
        }

        var name: String?

        if let wcV1Session = session.wcV1Session {
            name = wcV1Session.peerMeta.name
        } else if let wcV2Session = session.wcV2Session {
            name = wcV2Session.peer.name
        }

        let actionSheet = UIAlertController(
            title: nil,
            message: "wallet-connect-session-disconnect-message".localized(params: name.someString),
            preferredStyle: .actionSheet
        )

        let disconnectAction = UIAlertAction(title: "title-disconnect".localized, style: .destructive) { [weak self] _ in
            guard let self = self else {
                return
            }

            if let wcV1Session = session.wcV1Session {
                self.analytics.track(
                    .wcSessionDisconnected(
                        dappName: wcV1Session.peerMeta.name,
                        dappURL: wcV1Session.peerMeta.url.absoluteString,
                        address: wcV1Session.walletMeta?.accounts?.first
                    )
                )
            }

            loadingController?.startLoadingWithMessage("title-loading".localized)

            self.dataSource.disconnectFromSession(session)
        }

        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel)

        actionSheet.addAction(disconnectAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }

    private func updateScreenAfterDisconnecting() {
        let sessions = peraConnect.walletConnectCoordinator.getSessions()
        if sessions.isEmpty {
            delegate?.wcSessionShortListViewControllerDidClose(self)
            dismissScreen()
            return
        }

        dataSource.updateSessions(sessions)
        sessionListView.collectionView.reloadData()
        performLayoutUpdates()
    }
}

extension WCSessionShortListViewController {
    func peraConnect(
        _ peraConnect: PeraConnect,
        didPublish event: PeraConnectEvent
    ) {
        switch event {
        case .didDisconnectFromV1(let aSession):
            asyncMain {
                [weak self] in
                guard let self else { return }

                analytics.track(
                    .wcSessionDisconnected(
                        dappName: aSession.peerMeta.name,
                        dappURL: aSession.peerMeta.url.absoluteString,
                        address: aSession.walletMeta?.accounts?.first
                    )
                )

                loadingController?.stopLoading()

                updateScreenAfterDisconnecting()
            }
        case .didDisconnectFromV1Fail(_, let error):
            asyncMain {
                [weak self] in
                guard let self else { return }
                loadingController?.stopLoading()

                switch error {
                case .failedToDisconnectInactiveSession:
                    updateScreenAfterDisconnecting()
                case .failedToDisconnect:
                    bannerController?.presentErrorBanner(
                        title: "title-error".localized,
                        message: "title-generic-error".localized
                    )
                default: break
                }
            }
        case .didDisconnectFromV2:
            asyncMain {
                [weak self] in
                guard let self else { return }

                loadingController?.stopLoading()

                updateScreenAfterDisconnecting()
            }
        case .didDisconnectFromV2Fail(_, let error):
            asyncMain {
                [weak self] in
                guard let self else { return }

                loadingController?.stopLoading()

                bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: error.localizedDescription
                )
            }
        case .deleteSessionV2:
            asyncMain {
                [weak self] in
                guard let self else { return }

                loadingController?.stopLoading()

                updateScreenAfterDisconnecting()
            }
        default:
            break
        }
    }
}

protocol WCSessionShortListViewControllerDelegate: AnyObject {
    func wcSessionShortListViewControllerDidClose(_ controller: WCSessionShortListViewController)
}
