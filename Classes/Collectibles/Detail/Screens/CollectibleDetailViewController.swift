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

    private lazy var bottomBannerController = BottomActionableBannerController(
        presentingView: view,
        configuration: BottomActionableBannerControllerConfiguration(
            bottomMargin: 0,
            contentBottomPadding: view.safeAreaBottom + 20
        )
    )

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
        account: account,
        configuration: configuration
    )

    private var asset: CollectibleAsset
    private let account: Account?
    private let dataController: CollectibleDetailDataController

    private var displayedMedia: Media?

    init(
        asset: CollectibleAsset,
        account: Account,
        configuration: ViewControllerConfiguration
    ) {
        self.asset = asset
        self.account = account
        self.dataController = CollectibleDetailAPIDataController(
            api: configuration.api!,
            asset: asset,
            account: account
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
                self.displayedMedia = asset.media.first
                self.mediaPreviewController.updateAsset(asset)
            case .didResponseFail(let message):
                self.bottomBannerController.presentFetchError(
                    title: "title-generic-api-error".localized,
                    message: "title-error-description".localized(message),
                    actionTitle: "title-retry".localized,
                    actionHandler: {
                        [unowned self] in
                        self.bottomBannerController.dismissError()
                        self.dataController.retry()
                    }
                )
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

    override func linkInteractors() {
        super.linkInteractors()
        linkMediaPreviewInteractors()
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
        case .loading:
            let loadingCell = cell as? CollectibleDetailLoadingCell
            loadingCell?.startAnimating()
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
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .loading:
            let loadingCell = cell as? CollectibleDetailLoadingCell
            loadingCell?.stopAnimating()
        default: break
        }
    }
}

extension CollectibleDetailViewController {
    private func linkMediaPreviewInteractors() {
        mediaPreviewController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didSelectMedia:
                break
            case .didScrollToMedia(let media):
                self.displayedMedia = media
            }
        }
    }

    private func linkInteractors(
        _ cell: CollectibleDetailActionCell,
        for item: CollectibleDetailActionViewModel
    ) {
        cell.observe(event: .performSend) {
            [weak self] in
            guard let self = self else {
                return
            }

            guard let account = self.account,
                  let asset = account[self.asset.id] as? CollectibleAsset else {
                return
            }

            let draft = SendCollectibleDraft(
                fromAccount: self.account!,
                collectibleAsset: asset,
                image: self.mediaPreviewController.getExistingImage()
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
                by: .customPresent(
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

        if let downloadURL = displayedMedia?.downloadURL {
            items.append(downloadURL.absoluteString)
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

        uiInteractions.didCompleteTransaction = {
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

            if let urlString = item.source?.url,
               let url = URL(string: urlString) {
                self.open(url)
            }
        }
    }
}
