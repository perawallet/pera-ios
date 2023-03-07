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
//  LedgerApprovalViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

final class LedgerApprovalViewController:
    MacaroonUIKit.ScrollScreen,
    BottomSheetScrollPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }

    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var contextView = LedgerApprovalView()
    private lazy var theme = Theme()

    private let mode: Mode
    private let deviceName: String

    init(
        mode: Mode,
        deviceName: String
    ) {
        self.mode = mode
        self.deviceName = deviceName
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        contextView.startConnectionAnimation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        contextView.stopConnectionAnimation()
    }
    
    override func prepareLayout() {
        super.prepareLayout()

        addUI()
    }
}

extension LedgerApprovalViewController {
    private func addUI() {
        addBackground()
        addContext()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contextView.customize(theme.context)

        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        let viewModel = LedgerApprovalViewModel(mode: mode, deviceName: deviceName)
        contextView.bindData(viewModel)

        contextView.delegate = self
    }
}

extension LedgerApprovalViewController: LedgerApprovalViewDelegate {
    func ledgerApprovalViewDidTapCancelButton(_ ledgerApprovalView: LedgerApprovalView) {
        eventHandler?(.didCancel)
    }
}

extension LedgerApprovalViewController {
    enum Mode {
        case connection
        case approve
    }
}

extension LedgerApprovalViewController {
    enum Event {
        case didCancel
    }
}
