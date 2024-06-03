// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncommingASAsAPIDataController.swift

import Foundation
import MagpieCore

final class IncommingASAsAPIDataController {
    weak var delegate: IncommingASAsAPIDataControllerDelegate?
    
    private let api: ALGAPI
    private let session: Session
    
    init(api: ALGAPI, session: Session) {
        self.api = api
        self.session = session
    }
    
    func fetchRequests(addresses: [String]) {
        api.fetchIncommingASAsRequests(addresses) { [weak self] response in
            guard let self = self else {
                return
            }
            
            switch response {
            case .success(let requestList):
                self.delegate?.incommingASAsAPIDataController(
                    self, 
                    didFetch: requestList
                )
            case .failure(let apiError, _):
                self.delegate?.incommingASAsAPIDataController(
                    self,
                    didFailToFetchRequests: apiError.localizedDescription
                )
            }
        }
    }
}

protocol IncommingASAsAPIDataControllerDelegate: AnyObject {
    func incommingASAsAPIDataController(
        _ dataController: IncommingASAsAPIDataController,
        didFetch incommingASAsRequestList: IncommingASAsRequestList
    )
    
    func incommingASAsAPIDataController(
        _ dataController: IncommingASAsAPIDataController,
        didFailToFetchRequests error: String
    )
}
