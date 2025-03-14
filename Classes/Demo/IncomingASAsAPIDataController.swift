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

//   IncomingASAsAPIDataController.swift

import Foundation
import MagpieCore

final class IncomingASAsAPIDataController {
    weak var delegate: IncomingASAsAPIDataControllerDelegate?
    
    private let api: ALGAPI
    private let session: Session
    
    init(api: ALGAPI, session: Session) {
        self.api = api
        self.session = session
    }
    
    func fetchRequests(addresses: [String]) {
        api.fetchIncomingASAsRequests(addresses) { [weak self] response in
            guard let self = self else {
                return
            }
            
            switch response {
            case .success(let requestList):
                self.delegate?.incomingASAsAPIDataController(
                    self, 
                    didFetch: requestList
                )
            case .failure:
                break
            }
        }
    }
}

protocol IncomingASAsAPIDataControllerDelegate: AnyObject {
    func incomingASAsAPIDataController(
        _ dataController: IncomingASAsAPIDataController,
        didFetch incomingASAsRequestList: IncomingASAsRequestList
    )
}
