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
//   WCAssetAdditionTransactionViewController.swift

import UIKit

class WCAssetAdditionTransactionViewController: WCTransactionViewController {

    private lazy var assetAdditionTransactionView = WCAssetAdditionTransactionView()

    override var transactionView: WCSingleTransactionView? {
        return assetAdditionTransactionView
    }

    override func linkInteractors() {
        super.linkInteractors()
        assetAdditionTransactionView.delegate = self
    }
}

extension WCAssetAdditionTransactionViewController: WCAssetAdditionTransactionViewDelegate {
    func wcAssetAdditionTransactionViewDidOpenRawTransaction(_ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView) {

    }

    func wcAssetAdditionTransactionViewDidOpenAlgoExplorer(_ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView) {

    }

    func wcAssetAdditionTransactionViewDidOpenAssetURL(_ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView) {

    }

    func wcAssetAdditionTransactionViewDidOpenAssetMetadata(_ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView) {

    }
}
