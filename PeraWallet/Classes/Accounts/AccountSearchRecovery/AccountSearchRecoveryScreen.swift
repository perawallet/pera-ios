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

//   AccountSearchRecoveryScreen.swift

import Foundation
import UIKit
import SwiftUI
import pera_wallet_core
import MacaroonUIKit

class AccountSearchRecoveryScreen : BaseViewController {

    let recoveryView = RecoveryToolView()
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Defaults.background.uiColor
        navigationItem.title = String(localized: "search-recovery-accounts").capitalized
    }

    override func prepareLayout() {
        let hostingController = UIHostingController(rootView: recoveryView)
        addChild(hostingController)
        hostingController.didMove(toParent: self)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        hostingController.sizingOptions = [.intrinsicContentSize]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}
