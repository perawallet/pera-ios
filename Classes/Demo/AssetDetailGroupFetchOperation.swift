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
//   AssetDetailGroupFetchOperation.swift


import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class AssetDetailGroupFetchOperation: MacaroonUtils.AsyncOperation {
    typealias Error = HIPNetworkError<NoAPIModel>
    
    var input: Input
    
    private(set) var result: Result<Output, Error> =
        .failure(.unexpected(UnexpectedError(responseData: nil, underlyingError: nil)))
    
    private var ongoingEndpoints: [Int: EndpointOperatable] = [:]

    private let api: ALGAPI
    private let completionQueue: DispatchQueue

    private let apiQueryLimit = 100
    
    init(
        input: Input,
        api: ALGAPI
    ) {
        let address = input.account.unwrap(\.address) ?? ""

        self.input = input
        self.api = api
        self.completionQueue =
            DispatchQueue(
                label: "com.algorand.queue.operation.assetGroupFetch.\(address)",
                qos: .userInitiated
            )
    }
    
    override func main() {
        if finishIfCancelled() {
            return
        }
        
        if let error = input.error {
            result = .failure(error)
            finish()

            return
        }
        
        guard let account = input.account else {
            result = .failure(.unexpected(UnexpectedError(responseData: nil, underlyingError: nil)))
            finish()

            return
        }
        
        let assets = account.assets.someArray
        let newAssets: [ALGAsset]
        
        if let cacheAccount = input.cachedAccounts.account(for: account.address) {
            newAssets = Array(Set(assets).subtracting(cacheAccount.assets.someArray))
        } else {
            newAssets = assets
        }
        
        if self.finishIfCancelled() {
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        var newAssetDetails: [AssetID: AssetDecoration] = [:]
        var error: Error?
        
        newAssets.chunked(by: apiQueryLimit).enumerated().forEach {
            order, subNewAssets in
            
            dispatchGroup.enter()
            
            let endpoint =
                fetchAssetDetails(subNewAssets) { [weak self] result in
                    guard let self = self else {return }
                
                    self.ongoingEndpoints[order] = nil
                
                    switch result {
                    case .success(let subAssetDetails):
                        subAssetDetails.forEach {
                            newAssetDetails[$0.id] = $0
                        }
                    case .failure(let subError):
                        switch error {
                        case .none:
                            error = subError
                        case .some where !subError.isCancelled:
                            error = subError
                        default: break
                        }

                        self.cancelOngoingEndpoints()
                    }

                    dispatchGroup.leave()
                }
            ongoingEndpoints[order] = endpoint
        }
        
        dispatchGroup.notify(queue: completionQueue) { [weak self] in
            guard let self = self else { return }
            
            if let error = error {
                account.removeAllAssets()
                self.result = .failure(error)
            } else {
                if self.finishIfCancelled() {
                    return
                }

                var newStandardAssets: [StandardAsset] = []
                var newStandardAssetsIndexer: Account.StandardAssetIndexer = [:]

                var newCollectibles: [CollectibleAsset] = []
                var newCollectibleAssetsIndexer: Account.CollectibleAssetIndexer = [:]
                
                assets.enumerated().forEach { index, asset in
                    let id = asset.id
                    
                    if let assetDetail = newAssetDetails[id] ?? self.input.cachedAssetDetails[id] {
                        if assetDetail.isCollectible {
                            let collectible = CollectibleAsset(asset: asset, decoration: assetDetail)
                            newCollectibles.append(collectible)
                            newCollectibleAssetsIndexer[asset.id] = newCollectibleAssetsIndexer.count
                        } else {
                            let standardAsset = StandardAsset(asset: asset, decoration: assetDetail)
                            newStandardAssets.append(standardAsset)
                            newStandardAssetsIndexer[asset.id] = newStandardAssetsIndexer.count
                        }
                    }
                }
                
                account.setStandardAssets(
                    newStandardAssets,
                    newStandardAssetsIndexer
                )

                account.setCollectibleAssets(
                    newCollectibles,
                    newCollectibleAssetsIndexer
                )
                
                let output = Output(account: account, newAssetDetails: newAssetDetails)
                self.result = .success(output)
            }
            
            self.finish()
        }
    }

    override func finishIfCancelled() -> Bool {
        if !isCancelled {
            return false
        }

        result = .failure(.connection(.init(reason: .cancelled)))
        finish()

        return true
    }
    
    override func cancel() {
        cancelOngoingEndpoints()
        super.cancel()
    }
}

extension AssetDetailGroupFetchOperation {
    private func fetchAssetDetails(
        _ assets: [ALGAsset],
        onComplete handler: @escaping (Result<[AssetDecoration], Error>) -> Void
    ) -> EndpointOperatable {
        let ids = assets.map(\.id)
        let draft = AssetFetchQuery(ids: ids)
        return
            api.fetchAssetDetails(
                draft,
                queue: completionQueue,
                ignoreResponseOnCancelled: false
            ) { result in
                switch result {
                case .success(let assetList):
                    handler(.success(assetList.results))
                case .failure(let apiError, let apiErrorDetail):
                    let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                    handler(.failure(error))
                }
            }
    }
}

extension AssetDetailGroupFetchOperation {
    private func cancelOngoingEndpoints() {
        ongoingEndpoints.forEach {
            $0.value.cancel()
        }
        ongoingEndpoints = [:]
    }
}

extension AssetDetailGroupFetchOperation {
    struct Input {
        var account: Account?
        var cachedAccounts: AccountCollection = []
        var cachedAssetDetails: AssetDetailCollection = []
        var error: AssetDetailGroupFetchOperation.Error?
    }
    
    struct Output {
        let account: Account
        let newAssetDetails: [AssetID: AssetDecoration]
    }
}
