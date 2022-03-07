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
//   AccountCollectibleListViewController.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AccountCollectibleListViewController: BaseViewController {

    private lazy var collectibleListScreen = CollectibleListViewController(
        dataController: CollectibleListLocalDataController(
            galleryAccount: .single(account),
            sharedDataController: sharedDataController
        ),
        configuration: configuration
    )
    
    private let account: AccountHandle

    init(
        account: AccountHandle,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        super.init(configuration: configuration)
    }

    override func prepareLayout() {
        super.prepareLayout()
        add(collectibleListScreen)
    }

    override func linkInteractors() {
        super.linkInteractors()
        linkInteractors(collectibleListScreen)
    }
}

extension AccountCollectibleListViewController {
    private func linkInteractors(
        _ screen: CollectibleListViewController
    ) {
        screen.observe(event: .performReceiveAction) {
            [weak self] in
            guard let self = self else { return }

            self.openReceiveCollectible()
        }
    }
}

extension AccountCollectibleListViewController {
    private func openReceiveCollectible() {
        let controller = open(
            .receiveCollectibleAssetList(
                account: account,
                dataController: ReceiveCollectibleAssetListAPIDataController(api!)
            ),
            by: .present
        ) as? ReceiveCollectibleAssetListViewController

        let close = ALGBarButtonItem(kind: .close) {
            controller?.dismissScreen()
        }

        controller?.leftBarButtonItems = [close]
    }
}
