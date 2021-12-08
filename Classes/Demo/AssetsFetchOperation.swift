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
//   AssetsFetchOperation.swift


import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class AssetsFetchOperation: MacaroonUtils.AsyncOperation {
    typealias CompletionHandler = (Result<[AssetInformation], HIPNetworkError<NoAPIModel>>) -> Void
    
    var completionHandler: CompletionHandler?
    
    private var ongoingEndpoint: EndpointOperatable?
    
    private let ids: [AssetID]
    private let api: ALGAPI
    
    init(
        ids: [AssetID],
        api: ALGAPI
    ) {
        self.ids = ids
        self.api = api
    }
    
    override func main() {
        let draft = AssetFetchQuery(ids: ids)
        
        ongoingEndpoint =
            api.fetchAssetDetails(draft) { [weak self] result in
                guard let self = self else { return }
                
                if self.finishIfCancelled() {
                    return
                }
                
                self.ongoingEndpoint = nil
                
                switch result {
                case .success(let assetList):
                    let assets = assetList.results
                    
                    /// <todo>
                    /// ???
                    assets.forEach { self.api.session.assetInformations[$0.id] = $0 }
                    
                    self.completionHandler?(.success(assets))
                case .failure(let apiError, let apiErrorDetail):
                    let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                    self.completionHandler?(.failure(error))
                }
            }
    }
    
    override func cancel() {
        super.cancel()
        
        ongoingEndpoint?.cancel()
        ongoingEndpoint = nil
    }
}
