// Copyright 2022-2025 Pera Wallet, LDA

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
import UIKit
import pera_wallet_core

final class CollectibleDetailAPIDataController:
    CollectibleDetailDataController,
    SharedDataControllerObserver {
    var eventHandler: ((CollectibleDetailDataControllerEvent) -> Void)?

    private var lastSnapshot: Snapshot?
    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.collectibleDetail.updates",
        qos: .userInitiated
    )

    private lazy var amountFormatter: CollectibleAmountFormatter = .init()

    private var ongoingEndpoint: EndpointOperatable?

    private var account: Account
    private var asset: CollectibleAsset
    private lazy var currentAccountCollectibleStatus: AccountCollectibleStatus = getAccountCollectibleStatus()
    
    private let api: ALGAPI
    private let quickAction: AssetQuickAction?
    private let sharedDataController: SharedDataController

    init(
        api: ALGAPI,
        asset: CollectibleAsset,
        account: Account,
        quickAction: AssetQuickAction?,
        sharedDataController: SharedDataController
    ) {
        self.api = api
        self.asset = asset
        self.account = account
        self.quickAction = quickAction
        self.sharedDataController = sharedDataController
        
        sharedDataController.add(self)
    }
    
    deinit {
        sharedDataController.remove(self)
    }
}

extension CollectibleDetailAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            let updatedAccountAssetStatus = getAccountCollectibleStatus()
            
            if currentAccountCollectibleStatus != updatedAccountAssetStatus {
                currentAccountCollectibleStatus = updatedAccountAssetStatus

                deliverLoadingSnapshot()
                fetchAssetDetails()
            }
        }
    }
    
    func load() {
        currentAccountCollectibleStatus = getAccountCollectibleStatus()
        deliverLoadingSnapshot()
        fetchAssetDetails()
    }

    func reloadAfterOptInStatusUpdates() {
        currentAccountCollectibleStatus = getAccountCollectibleStatus()
        deliverContentSnapshot()
    }

    private func fetchAssetDetails() {
        cancelOngoingEndpoint()

        ongoingEndpoint = api.fetchAssetDetail(
            AssetDetailFetchDraft(id: asset.id),
            ignoreResponseOnCancelled: false
        ) { [weak self] response in
            guard let self = self else { return }

            switch response {
            case .success(let asset):
                self.asset = CollectibleAsset(
                    asset: ALGAsset(asset: self.asset),
                    decoration: asset
                )

                self.eventHandler?(.didFetch(self.asset))
                self.deliverContentSnapshot()
            case .failure(let error, _):
                var message: String

                if let statusCode = (error as? HTTPError)?.statusCode {
                    message = String(statusCode)
                } else {
                    message = error.description
                }

                self.eventHandler?(.didResponseFail(message: message))
            }
        }
    }

    private func cancelOngoingEndpoint() {
        ongoingEndpoint?.cancel()
        ongoingEndpoint = nil
    }
}

extension CollectibleDetailAPIDataController {
    func hasOptedIn() -> OptInStatus {
        return sharedDataController.hasOptedIn(
            assetID: asset.id,
            for: account
        )
    }

    func hasOptedOut() -> OptOutStatus {
        return sharedDataController.hasOptedOut(
            assetID: asset.id,
            for: account
        )
    }

    func getAccountCollectibleStatus() -> AccountCollectibleStatus {
        /// <todo>
        /// These side effects must fixed.
        if let updatedAccount = sharedDataController.accountCollection[account.address]?.value {
            account = updatedAccount
        }

        guard let updatedAsset = account[asset.id] else {
            return hasOptedIn() == .pending ? .optingIn : .notOptedIn
        }

        /// <note>
        /// There is a delay to mark an asset as NFT in the backend; thus, it is possible to
        /// interpret a newly-created NFT as a normal asset.
        switch updatedAsset {
        case let updatedCollectibleAsset as CollectibleAsset:
            asset.update(with: updatedCollectibleAsset)
        case let updatedStandardAsset as StandardAsset:
            asset.update(with: updatedStandardAsset)
        default:
            break
        }

        if hasOptedOut() == .pending {
            return .optingOut
        }

        if asset.isOwned {
            return .owned
        }

        return .optedIn
    }
    
    func getCurrentAccountCollectibleStatus() -> AccountCollectibleStatus {
        return currentAccountCollectibleStatus
    }
}

extension CollectibleDetailAPIDataController {
    private func deliverLoadingSnapshot() {
        deliverSnapshot {
            var snapshot = Snapshot()
            snapshot.appendSections([.loading])
            snapshot.appendItems(
                [.loading],
                toSection: .loading
            )
            return snapshot
        }
    }

    private func deliverContentSnapshot() {
        deliverSnapshot {
            [weak self] in
            guard let self = self else { return Snapshot() }

            var snapshot = Snapshot()

            self.addNameContent(&snapshot)
            self.addAccountInformationContentIfNeeded(&snapshot)
            self.addMediaContent(&snapshot)
            self.addActionContentIfNeeded(&snapshot)
            self.addPropertiesContent(&snapshot)
            self.addDescriptionContent(&snapshot)

            return snapshot
        }
    }

    private func addNameContent(
        _ snapshot: inout Snapshot
    ) {
        let itemIdentifier = CollectibleDetailNameItemIdentifier(asset)
        let item = CollectibleDetailItem.name(itemIdentifier)

        snapshot.appendSections([.name])
        snapshot.appendItems(
            [item],
            toSection: .name
        )
    }

    private func addAccountInformationContentIfNeeded(
        _ snapshot: inout Snapshot
    ) {
        /// <note> Opt-in flows shouldn't display account information.
        if quickAction == .optIn {
            return
        }

        let collectibleAssetItem = CollectibleAssetItem(
            account: account,
            asset: asset,
            amountFormatter: amountFormatter
        )
        let itemIdentifier = CollectibleDetailAccountInformationItemIdentifier(collectibleAssetItem)
        let item = CollectibleDetailItem.accountInformation(itemIdentifier)

        snapshot.appendSections([.accountInformation])
        snapshot.appendItems(
            [item],
            toSection: .accountInformation
        )
    }

    private func addMediaContent(
        _ snapshot: inout Snapshot
    ) {
        var mediaItems: [CollectibleDetailItem] = [.media(asset)]

        if currentAccountCollectibleStatus == .optedIn && !asset.isDestroyed {
            mediaItems.append(
                .error(
                    CollectibleMediaErrorViewModel(
                        .notOwner(isWatchAccount: account.authorization.isWatch)
                    )
                )
            )
        } else if !asset.mediaType.isSupported {
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

    private func addActionContentIfNeeded(
        _ snapshot: inout Snapshot
    ) {
        if quickAction != nil {
            return
        }

        if account.authorization.isWatch {
            return
        }

        if asset.isOwned {
            addActionsContent(&snapshot)
            return
        }

        /// <note>: Creators cannot opt-out from the asset.
        if asset.creator?.address == account.address {
            return
        }

        if account[asset.id] != nil {
            addOptOutActionContent(&snapshot)
        }
    }

    private func addActionsContent(
        _ snapshot: inout Snapshot
    ) {
        snapshot.appendSections([.action])
        snapshot.appendItems(
            [.quickActions],
            toSection: .action
        )
    }

    private func addOptOutActionContent(
        _ snapshot: inout Snapshot
    ) {
        snapshot.appendSections([.action])
        snapshot.appendItems(
            [.optOutAction],
            toSection: .action
        )
    }

    private func addDescriptionContent(
        _ snapshot: inout Snapshot
    ) {
        var descriptionItems: [CollectibleDetailItem] = []

        if !asset.description.isNilOrEmpty {
            descriptionItems.append(.description)
        }

        if asset.creator?.address != nil {
            descriptionItems.append(
                .creatorAccount(
                    CollectibleDetailCreatorAccountItemIdentifier(asset)
                )
            )
        }

        descriptionItems.append(
            .assetID(
                CollectibleDetailAssetIDItemIdentifier(asset)
            )
        )
        

        if let totalSupply = asset.totalSupply {
            amountFormatter.formattingContext = .listItem

            if let formattedTotalSupply = amountFormatter.format(totalSupply) {
                descriptionItems.append(
                    .information(
                        CollectibleTransactionInformation(
                            icon: nil,
                            title: String(localized: "title-total-supply"),
                            value: formattedTotalSupply,
                            isCollectibleSpecificValue: false
                        )
                    )
                )
            }
        }

        descriptionItems.append(
            .information(
                CollectibleTransactionInformation(
                    icon: .custom(img("icon-pera-logo")),
                    title: String(localized: "collectible-detail-show-on"),
                    value: String(localized: "collectible-detail-pera-explorer"),
                    isCollectibleSpecificValue: true,
                    actionURL: asset.explorerURL
                )
            )
        )

        snapshot.appendSections([.description])
        snapshot.appendItems(
            descriptionItems,
            toSection: .description
        )
    }

    private func addPropertiesContent(
        _ snapshot: inout Snapshot
    ) {
        if let properties = asset.properties,
           !properties.isEmpty {
            let propertyItems: [CollectibleDetailItem] = properties.map { .properties(CollectiblePropertyViewModel($0)) }

            snapshot.appendSections([.properties])
            snapshot.appendItems(
                propertyItems,
                toSection: .properties
            )
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

extension CollectibleDetailAPIDataController {
    func getImageDataToCopy(
        from url: URL
    ) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                  let data = data,
                  let image = UIImage(data: data) else {
                self.eventHandler?(.didImageResponseFail(url: url))
                return
            }
            self.eventHandler?(.didFetchImage(image))
        }.resume()
    }
    
    func downloadAssetMediaToSave(
        from url: URL,
        of type: MediaType,
        with fileExtension: String
    ) {
        let fileComponents = url.lastPathComponent.split(separator: ".", maxSplits: 1)
        URLSession.shared.downloadTask(with: url) { tempLocalUrl, _, error in
            do {
                guard error == nil,
                      let tempLocalUrl = tempLocalUrl,
                      let fileName = fileComponents.first?.string,
                      let destinationURL = try self.handleDownloadedCollectible(at: tempLocalUrl, with: fileName, and: fileExtension) else {
                    throw FileError.missingData
                }
                self.eventHandler?(.didFetchMedia(destinationURL))
            } catch {
                self.eventHandler?(.didMediaResponseFail(url: url))
            }
        }.resume()
    }
    
    private func handleDownloadedCollectible(
        at temporaryLocalUrl: URL,
        with fileName: String,
        and fileExtension: String
    ) throws -> URL? {
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        try FileManager.default.moveItem(at: temporaryLocalUrl, to: destinationURL)
        
        return destinationURL
    }
}
