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

//   CollectibleDetailAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore

final class CollectibleDetailAPIDataController: CollectibleDetailDataController {

    var eventHandler: ((CollectibleDetailDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?
    private let snapshotQueue = DispatchQueue(label: VariableLabels.collectibleDetailSnapshot.rawValue)

    private let api: ALGAPI
    private var asset: CollectibleAsset
    private let ownerAccount: Account?

    init(
        api: ALGAPI,
        asset: CollectibleAsset,
        ownerAccount: Account?
    ) {
        self.api = api
        self.asset = asset
        self.ownerAccount = ownerAccount
    }
}

extension CollectibleDetailAPIDataController {
    func load() {
        api.fetchAssetDetail(
            AssetDetailFetchDraft(id: asset.id)
        ) { [weak self] response in
            guard let self = self else { return }

            switch response {
            case .success(let asset):
                self.asset = CollectibleAsset(
                    asset: ALGAsset(id: asset.id),
                    decoration: asset
                )

                self.deliverContentSnapshot()
            case .failure(let error, _):
                self.deliverErrorSnapshot(error)
            }
        }
    }
}

extension CollectibleDetailAPIDataController {
    private func deliverLoadingSnapshot() {

    }

    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }

            var snapshot = Snapshot()

            self.addMediaContent(&snapshot)
            self.addActionContent(&snapshot)
            self.addDescriptionContent(&snapshot)
            self.addPropertiesContent(&snapshot)
            self.addExternalSourcesContent(&snapshot)

            return snapshot
        }
    }

    private func addMediaContent(
        _ snapshot: inout Snapshot
    ) {
        var mediaItems: [CollectibleDetailItem] = [.media(asset)]

        if ownerAccount == nil {
            mediaItems.append(
                .error(
                    CollectibleMediaErrorViewModel(
                        .notOwner
                    )
                )
            )
        } else if let mediaType = asset.mediaType,
                  !mediaType.isSupported {
            mediaItems.append(
                .error(
                    CollectibleMediaErrorViewModel(
                        .unsupported
                    )
                )
            )
        }

        snapshot.appendSections([.media])
        snapshot.appendItems(
            mediaItems,
            toSection: .media
        )
    }

    private func addActionContent(
        _ snapshot: inout Snapshot
    ) {
        let actionItem: [CollectibleDetailItem] = [
            .action(
                CollectibleDetailActionViewModel(
                    asset: asset,
                    ownerAccount: ownerAccount
                )
            )
        ]

        snapshot.appendSections([.action])
        snapshot.appendItems(
            actionItem,
            toSection: .action
        )
    }

    private func addDescriptionContent(
        _ snapshot: inout Snapshot
    ) {
        var descriptionItems: [CollectibleDetailItem] = []

        if !asset.description.isNilOrEmpty {
            descriptionItems.append(
                .description(
                    CollectibleDescriptionViewModel(
                        asset
                    )
                )
            )
        }

        if let ownerAccount = ownerAccount {
            descriptionItems.append(
                .information(
                    CollectibleTransactionInformation(
                        account: ownerAccount,
                        title: "collectible-detail-owner".localized,
                        value: ownerAccount.name.fallback(ownerAccount.address.shortAddressDisplay()),
                        isForegroundingValue: false
                    )
                )
            )
        }

        descriptionItems.append(
            .information(
                CollectibleTransactionInformation(
                    account: nil,
                    title: "title-asset-id".localized,
                    value: String(asset.id),
                    isForegroundingValue: false
                )
            )
        )

        if let collectionName = asset.collectionName,
           !collectionName.isEmpty {
            descriptionItems.append(
                .information(
                    CollectibleTransactionInformation(
                        account: nil,
                        title: "collectible-detail-collection-name".localized,
                        value: collectionName,
                        isForegroundingValue: true
                    )
                )
            )
        }

        if let assetTitle = asset.title,
           !assetTitle.isEmpty {
            descriptionItems.append(
                .information(
                    CollectibleTransactionInformation(
                        account: nil,
                        title: "collectible-detail-creator-name".localized,
                        value: assetTitle,
                        isForegroundingValue: true
                    )
                )
            )
        }

        if let creator = asset.creator?.address {
            descriptionItems.append(
                .information(
                    CollectibleTransactionInformation(
                        account: nil,
                        title: "collectible-detail-creator-address".localized,
                        value: creator.shortAddressDisplay(),
                        isForegroundingValue: true
                    )
                )
            )
        }

        snapshot.appendSections([.description])
        snapshot.appendItems(
            descriptionItems,
            toSection: .description
        )
    }

    private func addPropertiesContent(
        _ snapshot: inout Snapshot
    ) {
        if let properties = asset.traits,
           !properties.isEmpty {
            var propertyItems: [CollectibleDetailItem] = []

            for property in properties {
                let viewModel = CollectiblePropertyViewModel(property)
                propertyItems.append(.properties(viewModel))
            }

            snapshot.appendSections([.properties])
            snapshot.appendItems(
                propertyItems,
                toSection: .properties
            )
        }
    }

    private func addExternalSourcesContent(
        _ snapshot: inout Snapshot
    ) {
        var externalSourceItems: [CollectibleDetailItem] = [
            .external(
                CollectibleExternalSourceViewModel(
                    AlgoExplorerExternalSource()
                )
            )
        ]

        if !api.isTestNet {
            externalSourceItems.append(
                .external(
                    CollectibleExternalSourceViewModel(
                        NFTExplorerExternalSource()
                    )
                )
            )
        }

        snapshot.appendSections([.external])
        snapshot.appendItems(
            externalSourceItems,
            toSection: .external
        )
    }

    private func deliverErrorSnapshot(
        _ error: APIError
    ) {
        deliverSnapshot {
            let snapshot = Snapshot()

            return snapshot
        }
    }

    private func deliverSnapshot(
        _ snapshot: @escaping () -> Snapshot
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }
            self.publish(.didUpdate(snapshot()))
        }
    }
}

extension CollectibleDetailAPIDataController {
    private func publish(
        _ event: CollectibleDetailDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }

            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}
