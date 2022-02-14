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
//   InvalidAccountOptionsViewController.swift

import Foundation
import MacaroonBottomSheet
import MacaroonUIKit
import UIKit

final class InvalidAccountOptionsViewController:
    BaseScrollViewController,
    BottomSheetPresentable {
    var uiInteractions = InvalidAccountOptionsUIInteractions()

    private lazy var contextView = VStackView()

    private let account: AccountHandle
    
    private let theme: InvalidAccountOptionsViewControllerTheme

    init(
        account: AccountHandle,
        configuration: ViewControllerConfiguration,
        theme: InvalidAccountOptionsViewControllerTheme = .init()
    ) {
        self.account = account
        self.theme = theme

        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }
    
    private func build() {
        addBackground()
        addContext()
        addError()
        addActions()
    }
}

extension InvalidAccountOptionsViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }
    
    private func addContext() {
        contentView.addSubview(contextView)
        contextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.contentPaddings.top,
            leading: theme.contentPaddings.leading,
            bottom: theme.contentPaddings.bottom,
            trailing: theme.contentPaddings.trailing
        )
        contextView.isLayoutMarginsRelativeArrangement = true
        contextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
    
    private func addError() {
        let errorView = ErrorView()

        errorView.customize(theme.error)
        errorView.bindData(PortfolioCalculationErrorViewModel())
        
        contextView.addArrangedSubview(errorView)
        contextView.setCustomSpacing(
            theme.spacingBetweenErrorAndAction,
            after: errorView
        )
    }
    
    private func addActions() {
        addCopyAddressAction()
        addViewPassphraseAction()
        addShowQrCodeAction()
    }
    
    private func addCopyAddressAction() {
        addAction(
            CopyAddressListActionViewModel(account.value),
            #selector(copyAddress)
        )
    }
    
    private func addViewPassphraseAction() {
        addAction(
            ViewPassphraseListActionViewModel(),
            #selector(viewPassphrase)
        )
    }
    
    private func addShowQrCodeAction() {
        addAction(
            ShowQrCodeListActionViewModel(),
            #selector(showQrCode)
        )
    }
    
    private func addAction(
        _ viewModel: ListActionViewModel,
        _ selector: Selector
    ) {
        let actionView = ListActionView()
        
        actionView.customize(theme.action)
        actionView.bindData(viewModel)
        
        contextView.addArrangedSubview(actionView)
        
        actionView.addTouch(
            target: self,
            action: selector
        )
    }
}

extension InvalidAccountOptionsViewController {
    @objc
    private func copyAddress() {
        closeScreen(by: .dismiss, animated: true) { [weak self] in
            self?.uiInteractions.didTapCopyAddress?()
        }
    }
    
    @objc
    private func viewPassphrase() {
        closeScreen(by: .dismiss, animated: true) { [weak self] in
            self?.uiInteractions.didTapViewPassphrase?()
        }
    }
    
    @objc
    private func showQrCode() {
        closeScreen(by: .dismiss, animated: true) { [weak self] in
            self?.uiInteractions.didTapShowQRCode?()
        }
    }
}

extension InvalidAccountOptionsViewController {
    struct InvalidAccountOptionsUIInteractions {
        var didTapCopyAddress: EmptyHandler?
        var didTapViewPassphrase: EmptyHandler?
        var didTapShowQRCode: EmptyHandler?
    }
}
