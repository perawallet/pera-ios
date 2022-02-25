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

//   BuyAlgoHomeScreen.swift

import MacaroonUIKit
import UIKit
import SafariServices

final class BuyAlgoHomeScreen: BaseViewController {
    weak var delegate: BuyAlgoHomeScreenDelegate?

    private lazy var homeView = BuyAlgoHomeView()

    private var safariViewController: SFSafariViewController?

    var transactionDraft: MoonpayTransactionDraft?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addHomeView()
    }
    
    override func setListeners() {
        super.setListeners()
        
        homeView.observe(event: .closeScreen) {
            [weak self] in
            guard let self = self else { return }
            self.dismissScreen()
        }
        
        homeView.observe(event: .buyAlgo) { [weak self] in
            guard let self = self else {
                return
            }

            if let transactionDraft = self.transactionDraft {
                self.openMoonPay(for: transactionDraft)
                return
            }

            self.open(
                .accountSelection(transactionAction: .buyAlgo, delegate: self),
                by: .push
            )
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didRedirectFromMoonPay(_:)),
            name: .didRedirectFromMoonPay,
            object: nil)
    }
}

extension BuyAlgoHomeScreen {
    @objc
    private func didRedirectFromMoonPay(_ notification: Notification) {
        guard
            let moonpayParams = notification.userInfo?[MoonpayParams.notificationObjectKey] as? MoonpayParams
        else {
            return
        }

        safariViewController?.dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            self.delegate?.buyAlgoHomeScreen(self, didCompletedTransaction: moonpayParams)
        }
    }
}

extension BuyAlgoHomeScreen {
    private func addHomeView() {
        homeView.customize(MoonpayIntroductionViewTheme())
        homeView.bindData(MoonpayIntroductionViewModel())
        
        view.addSubview(homeView)
        homeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension BuyAlgoHomeScreen: SelectAccountViewControllerDelegate {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for transactionAction: TransactionAction
    ) {
        guard transactionAction == .buyAlgo else {
            return
        }

        let address = "tb1q3pt955j4h7wehmgesgsr4vjw6l5ssr5q4fwvll"

        let transactionDraft = MoonpayTransactionDraft(address: address)
        self.transactionDraft = transactionDraft

        openMoonPay(for: transactionDraft)
    }

    private func openMoonPay(for draft: MoonpayTransactionDraft) {
        let address = "tb1q3pt955j4h7wehmgesgsr4vjw6l5ssr5q4fwvll"
        self.safariViewController = self.open(
            URL(
                string: "https://buy-sandbox.moonpay.com?apiKey=pk_test_g6Ojf6eciZZvUYyNb8WHzZml9l48Ri0u&currencyCode=btc&walletAddress=\(address)&redirectURL=algorand://\(address)"
            )
        )
    }
}

protocol BuyAlgoHomeScreenDelegate: AnyObject {
    func buyAlgoHomeScreen(
        _ screen: BuyAlgoHomeScreen,
        didCompletedTransaction params: MoonpayParams
    )
}
