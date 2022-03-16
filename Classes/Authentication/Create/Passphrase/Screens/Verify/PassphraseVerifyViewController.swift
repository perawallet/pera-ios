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
//  PassphraseVerifyViewController.swift

import UIKit
import AVFoundation

final class PassphraseVerifyViewController: BaseScrollViewController {
    private lazy var passphraseVerifyView = PassphraseVerifyView()
        
    private lazy var theme = Theme()

    private lazy var accountOrdering = AccountOrdering(
        sharedDataController: sharedDataController,
        session: session!
    )

    private lazy var dataSource: PassphraseVerifyDataSource = {
        if let privateKey = session?.privateData(for: "temp") {
            return PassphraseVerifyDataSource(privateKey: privateKey)
        }
        fatalError("Private key should be set.")
    }()

    private let flow: AccountSetupFlow

    init(
        flow: AccountSetupFlow,
        configuration: ViewControllerConfiguration
    ) {
        self.flow = flow

        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        customizeBackground()
    }

    private func customizeBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        scrollView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        contentView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func prepareLayout() {
        super.prepareLayout()
       
        passphraseVerifyView.customize(PassphraseVerifyViewTheme())
        
        contentView.addSubview(passphraseVerifyView)
        passphraseVerifyView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )

        passphraseVerifyView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
}
