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
//   TransactionModalViewController.swift

import Macaroon
import UIKit

final class TransactionModalViewController: BaseViewController {
    weak var delegate: TransactionModalViewControllerDelegate?

    private lazy var chromeView = UIView()
    private lazy var transactionModalView = TransactionModalView()
    private lazy var theme = Theme()
    
    override func setListeners() {
        transactionModalView.sendButton.addTarget(self, action: #selector(notifyDelegateToSend), for: .touchUpInside)
        transactionModalView.receiveButton.addTarget(self, action: #selector(notifyDelegateToReceive), for: .touchUpInside)
    }

    override func prepareLayout() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addChrome(theme)
        addTransacationModal(theme)
    }
}

extension TransactionModalViewController {
    func addChrome(_ theme: Theme) {
        chromeView.customizeAppearance(theme.chromeStyle)

        view.addSubview(chromeView)
        chromeView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    func addTransacationModal(_ theme: Theme) {
        transactionModalView.customize(theme.transactionModalViewTheme)

        view.addSubview(transactionModalView)
        transactionModalView.snp.makeConstraints {
            $0.fitToHeight(theme.modalHeight)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
}

extension TransactionModalViewController {
    @objc
    private func notifyDelegateToSend() {
        delegate?.transactionModalViewControllerDidSend(self)
    }

    @objc
    private func notifyDelegateToReceive() {
        delegate?.transactionModalViewControllerDidReceive(self)
    }
}

protocol TransactionModalViewControllerDelegate: AnyObject {
    func transactionModalViewControllerDidSend(_ transactionModalViewController: TransactionModalViewController)
    func transactionModalViewControllerDidReceive(_ transactionModalViewController: TransactionModalViewController)
}
