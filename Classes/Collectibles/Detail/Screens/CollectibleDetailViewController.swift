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

//   CollectibleDetailViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class CollectibleDetailViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = CollectibleListLayout.build()
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

    private lazy var listLayout = CollectibleDetailLayout(dataSource: dataSource)
    private lazy var dataSource = CollectibleDetailDataSource(
        collectionView: listView,
        mediaPreviewController: mediaPreviewController
    )

    private lazy var mediaPreviewController = CollectibleMediaPreviewViewController(
        asset: asset,
        ownerAccount: ownerAccount,
        configuration: configuration
    )

    private var asset: CollectibleAsset
    private let ownerAccount: Account?
    private let dataController: CollectibleDetailDataController

    init(
        asset: CollectibleAsset,
        ownerAccount: Account?,
        configuration: ViewControllerConfiguration
    ) {
        self.asset = asset
        self.ownerAccount = ownerAccount
        self.dataController = CollectibleDetailAPIDataController(
            api: configuration.api!,
            asset: asset,
            ownerAccount: ownerAccount
        )
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.dataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            case .didFetch(let asset):
                self.asset = asset
                self.mediaPreviewController.updateAsset(asset)
            }
        }

        view.backgroundColor = AppColors.Shared.System.background.uiColor

        dataController.load()

        addChild(mediaPreviewController)
        mediaPreviewController.didMove(toParent: self)
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

extension CollectibleDetailViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension CollectibleDetailViewController {
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
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            minimumLineSpacingForSectionAt: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            minimumInteritemSpacingForSectionAt: section
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
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            referenceSizeForHeaderInSection: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .action(let item):
            linkInteractors(
                cell as! CollectibleDetailActionCell,
                for: item
            )
        case .external(let item):
            linkInteractors(
                cell as! CollectibleExternalSourceCell,
                for: item
            )
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {

    }
}

extension CollectibleDetailViewController {
    private func linkInteractors(
        _ cell: CollectibleDetailActionCell,
        for item: CollectibleDetailActionViewModel
    ) {
        cell.observe(event: .performSend) {
            [weak self] in
            guard let self = self else {
                return
            }

            let draft = SendCollectibleDraft(
                fromAccount: self.ownerAccount!,
                collectibleAsset: self.asset,
                image: nil /// Pass the image so we will not load.
            )

            self.open(
                .sendCollectible(
                    draft: draft,
                    transactionController: TransactionController(
                        api: self.api!,
                        bannerController: self.bannerController
                    ),
                    uiInteractionsHandler: self.linkSendCollectibleUIInteractions()
                ),
                by: .customPresentWithoutNavigationController(
                    presentationStyle: .overCurrentContext,
                    transitionStyle: .crossDissolve,
                    transitioningDelegate: nil
                ),
                animated: false
            )
        }

        cell.observe(event: .performShare) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.shareCollectible()
        }
    }

    private func shareCollectible() {
        var items: [Any] = []

        if let name = asset.title {
            items.append(name)
        }

        if let downloadURL = self.asset.media.first?.downloadURL {
            items.append(downloadURL.absoluteString)

            loadingController?.startLoadingWithMessage("title-loading".localized)

            let imageView = URLImageView()
            imageView.load(from: PNGImageSource(url: downloadURL)) {
                [weak self] _ in
                guard let self = self else { return }

                self.loadingController?.stopLoading()

                if let image = imageView.imageContainer.image {
                    items.append(image)
                }

                self.presentShareController(items)
            }

            return
        }

        presentShareController(items)
    }

    private func presentShareController(
        _ items: [Any]
    ) {
        open(
            .shareActivity(
                items: items
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func linkSendCollectibleUIInteractions()
    -> SendCollectibleViewController.SendCollectibleUIInteractions {
        var uiInteractions = SendCollectibleViewController.SendCollectibleUIInteractions()

        uiInteractions.didSendTransactionSuccessfully = {
            [weak self] controller in
            guard let self = self else {
                return
            }

            controller.dismissScreen(animated: false) {
                self.popScreen(animated: false)
            }
        }

        return uiInteractions
    }

    private func linkInteractors(
        _ cell: CollectibleExternalSourceCell,
        for item: CollectibleExternalSourceViewModel
    ) {
        cell.observe(event: .performAction) {
            [weak self] in
            guard let self = self else { return }

            if let source = item.source,
               let urlString = source.getURL(
                    for: self.asset.id,
                    in: self.api!.network
               ),
               let url = URL(string: urlString) {
                self.open(url)
            }
        }
    }
}
