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

//   CollectiblesViewController.swift

import UIKit
import MacaroonUIKit

final class CollectiblesViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout,
    UIInteractionObservable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performReceiveAction: UIBlockInteraction()
    ]

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = CollectibleListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var listLayout = CollectibleListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = CollectibleListDataSource(listView)

    private let dataController: CollectibleListDataController

    init(
        dataController: CollectibleListDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func prepareLayout() {
        super.prepareLayout()
        build()
    }

    override func setListeners() {
        super.setListeners()

        listView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let loadingCell =
        listView
            .visibleCells
            .first { $0 is CollectibleListLoadingViewCell } as? CollectibleListLoadingViewCell
        loadingCell?.startAnimating()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        let loadingCell =
        listView
            .visibleCells
            .first { $0 is CollectibleListLoadingViewCell } as? CollectibleListLoadingViewCell
        loadingCell?.stopAnimating()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case .didUpdate(let snapshot):
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }

        dataController.load()
    }

    private func build() {
        addListView()
    }
}

extension CollectiblesViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension CollectiblesViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }

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

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .search:
            linkInteractors(cell as! CollectibleSearchInputCell)
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? CollectibleListLoadingViewCell
                loadingCell?.startAnimating()
            case .noContent:
                linkInteractors(cell as! NoContentWithActionIllustratedCell)
            default:
                break
            }
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? CollectibleListLoadingViewCell
                loadingCell?.stopAnimating()
            default:
                break
            }
        default:
            break
        }
    }
}

extension CollectiblesViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .collectible(let item):
            switch item {
            case .cell(_):
                /// <todo>: Navigate to detail screen.
                break
            case .footer:
                openReceiveCollectibleAccountList()
            }
        default:
            break
        }
    }
}

extension CollectiblesViewController {
    private func linkInteractors(
        _ cell: NoContentWithActionIllustratedCell
    ) {
        cell.handlers.didTapActionView = {
            [weak self] in
            guard let self = self else {
                return
            }

            self.openReceiveCollectibleAccountList()
        }
    }

    private func linkInteractors(
        _ cell: CollectibleSearchInputCell
    ) {
        cell.delegate = self
    }
}

extension CollectiblesViewController {
    private func openReceiveCollectibleAccountList() {
        let interaction = uiInteractions[.performReceiveAction] as? UIBlockInteraction
        interaction?.notify()
    }
}

extension CollectiblesViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else {
            return
        }

        if query.isEmpty {
            dataController.resetSearch()
            return
        }

        dataController.search(for: query)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }

    func searchInputViewDidTapRightAccessory(_ view: SearchInputView) {
        dataController.resetSearch()
    }
}

extension CollectiblesViewController {
    enum Event {
        case performReceiveAction
    }
}
