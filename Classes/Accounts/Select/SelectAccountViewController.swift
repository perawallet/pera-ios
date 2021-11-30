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
//   SelectAccountViewController.swift


import Foundation
import UIKit

final class SelectAccountViewController: BaseViewController {
    private let layout = Layout<LayoutConstants>()
    private lazy var accountListDataSource = SelectAccountViewControllerDataSource(
        session: UIApplication.shared.appConfiguration?.session
    )
    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = AppColors.Shared.System.background.uiColor
        collectionView.register(AssetPreviewCell.self)
        collectionView.contentInset.top = 28
        return collectionView
    }()

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }

        leftBarButtonItems = [closeBarButtonItem]
    }

    override func configureAppearance() {
        view.backgroundColor = Colors.Background.tertiary
        navigationItem.title = "send-algos-select".localized
    }

    override func setListeners() {
        listView.delegate = self
        listView.dataSource = accountListDataSource
        listView.register(
            AssetPreviewCell.self,
            forCellWithReuseIdentifier: AssetPreviewCell.reusableIdentifier
        )

    }

    override func prepareLayout() {
        setupSelectAccountViewLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        listView.reloadData()
    }
}

extension SelectAccountViewController {
    private func setupSelectAccountViewLayout() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview().inset(24)
            $0.top.bottom.equalToSuperview()
        }
    }
}

extension SelectAccountViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let itemHeight: CGFloat = 72.0
    }
}

extension SelectAccountViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: layout.current.itemHeight)
    }
}
