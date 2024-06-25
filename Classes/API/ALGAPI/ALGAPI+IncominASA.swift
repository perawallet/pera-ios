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

//   ALGAPI+IncominASA.swift

import Foundation
import MagpieCore
import MagpieExceptions

extension ALGAPI {
    
    @discardableResult
    func fetchIncomingASAsRequests(
        _ addresses: [String],
        onCompleted handler: @escaping (Response.ModelResult<IncomingASAsRequestList>) -> Void
    ) -> EndpointOperatable {        
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.asaInboxesRequests)
            .method(.get)
            .query(IncomingASAsRequestsQuery(addresses: addresses.joined(separator: ",")))
            .completionHandler(handler)
            .execute()
    }
    
    @discardableResult
    func fetchIncomingASAsRequest(
        _ address: String,
        with cursorQuery: IncomingASAsRequestDetailQuery,
        onCompleted handler: @escaping (Response.ModelResult<IncomingASAsRequestDetailList>) -> Void
    ) -> EndpointOperatable {
        
        return EndpointBuilder(api: self)
            .base(.mobileV1(network))
            .path(.asaInboxesRequest, args: address)
            .method(.get)
            .query(cursorQuery)
            .completionHandler(handler)
            .execute()
    }
}
