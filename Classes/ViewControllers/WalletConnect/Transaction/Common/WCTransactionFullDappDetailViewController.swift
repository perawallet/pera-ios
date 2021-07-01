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
//   WCTransactionFullDappDetailViewController.swift

import UIKit

class WCTransactionFullDappDetailViewController: BaseViewController {

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var fullDappDetailView = WCTransactionFullDappDetailView()

    private let wcSession: WCSession

    init(wcSession: WCSession, configuration: ViewControllerConfiguration) {
        self.wcSession = wcSession
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
        fullDappDetailView.bind(WCTransactionDappMessageViewModel(session: wcSession, imageSize: CGSize(width: 60.0, height: 60.0)))
    }

    override func prepareLayout() {
        prepareWholeScreenLayoutFor(fullDappDetailView)
    }
}

extension WCTransactionFullDappDetailViewController: WCTransactionFullDappDetailViewDelegate {
    func wcTransactionFullDappDetailViewDidCloseScreen(_ wcTransactionFullDappDetailView: WCTransactionFullDappDetailView) {
        dismissScreen()
    }
}
