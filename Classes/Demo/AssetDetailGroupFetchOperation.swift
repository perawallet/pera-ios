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
    private let completionQueue =
        DispatchQueue(label: "com.algorand.queue.operation.assetGroupFetch", qos: .userInitiated)
    private let apiQueryLimit = 100
    
    init(
        input: Input,
        api: ALGAPI
    ) {
        self.input = input
        self.api = api
    }
    
    override func main() {
        if self.finishIfCancelled() {
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
        let newAssets: [Asset]
        
        if let cacheAccount = input.cachedAccounts.account(for: account.address) {
            newAssets = Array(Set(assets).subtracting(cacheAccount.assets.someArray))
        } else {
            newAssets = assets
        }
        
        if self.finishIfCancelled() {
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        var newAssetDetails: [AssetID: AssetInformation] = [:]
        var error: Error?
        
        newAssets.chunked(by: apiQueryLimit).enumerated().forEach {
            order, subNewAssets in
            
            dispatchGroup.enter()
            
            let endpoint =
                fetchAssetDetails(subNewAssets) { [weak self] result in
                    dispatchGroup.leave()
                
                    guard let self = self else {return }
                
                    self.ongoingEndpoints[order] = nil
                
                    switch result {
                    case .success(let subAssetDetails):
                        subAssetDetails.forEach {
                            newAssetDetails[$0.id] = $0
                        }
                    case .failure(let subError):
                        if subError.isCancelled {
                            return
                        }

                        error = subError

                        self.cancelOngoingEndpoints()
                    }
                }
            ongoingEndpoints[order] = endpoint
        }
        
        dispatchGroup.notify(queue: completionQueue) { [weak self] in
            guard let self = self else { return }
            
            if self.finishIfCancelled() {
                return
            }
            
            if let error = error {
                account.removeAllCompoundAssets()
                self.result = .failure(error)
            } else {
                var newCompoundAssets: [CompoundAsset] = []
                var newCompoundAssetsIndexer: Account.CompoundAssetIndexer = [:]
                
                assets.enumerated().forEach { index, asset in
                    let id = asset.id
                    
                    if let assetDetail = newAssetDetails[id] ?? self.input.cachedAssetDetails[id] {
                        newCompoundAssets.append(CompoundAsset(asset, assetDetail))
                        newCompoundAssetsIndexer[asset.id] = index
                    }
                }
                
                account.setCompoundAssets(
                    newCompoundAssets,
                    newCompoundAssetsIndexer
                )
                
                let output = Output(account: account, newAssetDetails: newAssetDetails)
                self.result = .success(output)
            }
            
            self.finish()
        }
    }
    
    override func cancel() {
        cancelOngoingEndpoints()
        super.cancel()
    }
}

extension AssetDetailGroupFetchOperation {
    private func fetchAssetDetails(
        _ assets: [Asset],
        onComplete handler: @escaping (Result<[AssetInformation], Error>) -> Void
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
        let newAssetDetails: [AssetID: AssetInformation]
    }
}
