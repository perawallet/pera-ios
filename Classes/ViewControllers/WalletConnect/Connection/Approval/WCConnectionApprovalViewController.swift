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
//   WCConnectionApprovalViewController.swift

import UIKit

class WCConnectionApprovalViewController: BaseViewController {

    private lazy var connectionApprovalView = WCConnectionApprovalView()

    override func configureAppearance() {
        super.configureAppearance()
    }

    override func prepareLayout() {
        super.prepareLayout()
        prepareWholeScreenLayoutFor(connectionApprovalView)
    }

    override func linkInteractors() {
        super.linkInteractors()
        connectionApprovalView.delegate = self
    }
}

extension WCConnectionApprovalViewController {

}

extension WCConnectionApprovalViewController: WCConnectionApprovalViewDelegate {
    func wcConnectionApprovalViewDidApproveConnection(_ wcConnectionApprovalView: WCConnectionApprovalView) {

    }

    func wcConnectionApprovalViewDidRejectConnection(_ wcConnectionApprovalView: WCConnectionApprovalView) {

    }
}
