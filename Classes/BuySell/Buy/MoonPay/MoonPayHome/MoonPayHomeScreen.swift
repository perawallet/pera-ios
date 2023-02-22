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

//   MoonPayHomeScreen.swift

import MacaroonUIKit
import UIKit
import SafariServices
import MacaroonUtils

final class MoonPayHomeScreen: BaseViewController, NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []

    weak var delegate: MoonPayHomeScreenDelegate?

    private lazy var contentView = MoonPayHomeView()

    private var moonPayDraft: MoonPayDraft

    init(draft: MoonPayDraft, configuration: ViewControllerConfiguration) {
        self.moonPayDraft = draft
        super.init(configuration: configuration)
    }

    override var shouldShowNavigationBar: Bool {
        return false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopObservingNotifications()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addContent()
    }
    
    override func setListeners() {
        super.setListeners()

        observe(notification: .didRedirectFromMoonPay) {
            [unowned self] notification in

            self.didRedirectFromMoonPay(notification)
        }
    }

    override func linkInteractors() {
        super.linkInteractors()

        contentView.startObserving(event: .close) {
            [weak self] in
            guard let self = self else { return }
            self.dismissScreen()
        }

        contentView.startObserving(event: .buyAlgo) { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.api.isTestNet {
                self.presentTestNetAlert()
                return
            }

            self.analytics.track(.moonPay(type: .tapBuy))

            if self.moonPayDraft.hasValidAddress() {
                self.openMoonPay(for: self.moonPayDraft)
                return
            }

            let draft = SelectAccountDraft(
                transactionAction: .buyAlgo,
                requiresAssetSelection: false
            )

            self.open(
                .accountSelection(draft: draft, delegate: self),
                by: .push
            )
        }
    }
}

extension MoonPayHomeScreen {
    private func didRedirectFromMoonPay(_ notification: Notification) {
        guard
            let moonPayParams = notification.userInfo?[MoonPayParams.notificationObjectKey] as? MoonPayParams
        else {
            delegate?.moonPayHomeScreenDidFailedTransaction(self)
            return
        }

        analytics.track(.moonPay(type: .completed))
        delegate?.moonPayHomeScreen(self, didCompletedTransaction: moonPayParams)
    }
}

extension MoonPayHomeScreen {
    private func addContent() {
        contentView.customize(MoonPayHomeViewTheme())
        contentView.bindData(MoonPayHomeViewModel())
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension MoonPayHomeScreen: SelectAccountViewControllerDelegate {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for draft: SelectAccountDraft
    ) {
        guard draft.transactionAction == .buyAlgo else {
            return
        }

        let moonPayDraft = MoonPayDraft()
        moonPayDraft.address = account.address
        openMoonPay(for: moonPayDraft)
    }

    private func openMoonPay(for draft: MoonPayDraft) {
        guard let address = draft.address else {
            return
        }

        let deeplinkURL = "\(target.deeplinkConfig.moonpay.scheme)://\(address)"
        let moonPaySignDraft = MoonPaySignDraft(walletAddress: address, redirectUrl: deeplinkURL)

        loadingController?.startLoadingWithMessage("title-loading".localized)

        api?.getSignedMoonPayURL(moonPaySignDraft) { [weak self] response in
            guard let self = self else {
                return
            }

            self.loadingController?.stopLoading()

            switch response {
            case .failure:
                break
            case let .success(response):
                if let url = response.url {
                    self.openMoonPay(url: url)
                }
            }
        }
    }

    private func openMoonPay(url: URL) {
        self.open(url)
    }
    
    private func presentTestNetAlert() {
        displaySimpleAlertWith(
            title: "title-not-available".localized,
            message: "moonpay-transaction-testnet-not-available-description".localized,
            handler: nil
        )
    }
}

protocol MoonPayHomeScreenDelegate: AnyObject {
    func moonPayHomeScreen(
        _ screen: MoonPayHomeScreen,
        didCompletedTransaction params: MoonPayParams
    )
    func moonPayHomeScreenDidFailedTransaction(
        _ screen: MoonPayHomeScreen
    )
}
