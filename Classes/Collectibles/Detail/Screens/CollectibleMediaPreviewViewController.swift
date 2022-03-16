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

//   CollectibleMediaPreviewViewController.swift

import UIKit
import MacaroonUIKit

final class CollectibleMediaPreviewViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = CollectibleMediaPreviewLayout.build()
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

    private lazy var listLayout = CollectibleMediaPreviewLayout(dataSource: dataSource)
    private lazy var dataSource = CollectibleMediaPreviewDataSource(listView)

    private let asset: Collectible

    init(
        asset: Collectible,
        configuration: ViewControllerConfiguration
    ) {
        self.asset = asset
        super.init(configuration: configuration)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addListView()
    }

    override func setListeners() {
        super.setListeners()
        listView.delegate = self
    }
}

extension CollectibleMediaPreviewViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}
