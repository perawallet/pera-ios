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

//   SortCollectibleListViewController.swift

import Foundation
import UIKit

final class SortCollectibleListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = SortCollectibleListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var listLayout = SortCollectibleListLayout(
        listDataSource: listDataSource
    )

    private lazy var listDataSource = SortCollectibleListDataSource(
        listView,
        dataController: dataController
    )

    private let dataController: SortCollectibleListDataController

    init(
        dataController: SortCollectibleListDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
        bindNavigationItemTitle()
    }

    override func prepareLayout() {
        super.prepareLayout()
        addList()
    }
}

extension SortCollectibleListViewController {
    private func addBarButtons() {
        let doneBarButtonItem = ALGBarButtonItem(
            kind: .doneGreen
        ) {}

        rightBarButtonItems = [doneBarButtonItem]
    }

    private func bindNavigationItemTitle() {
        title = "title-sort".localized
    }
}

extension SortCollectibleListViewController {
    private func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}


extension SortCollectibleListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

extension SortCollectibleListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard listDataSource.itemIdentifier(for: indexPath) != nil else { return }

        dataController.selectItem(at: indexPath)
    }
}

extension SortCollectibleListViewController {
    enum Event {
        case didComplete
    }
}
