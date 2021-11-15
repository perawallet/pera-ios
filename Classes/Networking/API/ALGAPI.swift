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
//  API.swift

import Foundation
import MacaroonApplication
import MacaroonUtils
import MagpieAlamofire
import MagpieCore

final class ALGAPI: API {
    private lazy var apiInterceptor = ALGAPIInterceptor()

    let session: Session

    var isTestNet: Bool {
        return apiInterceptor.isTestNet
    }

    init(session: Session, networkMonitor: NetworkMonitor? = nil) {
        self.session = session

        super.init(
            base: Environment.current.serverApi,
            networking: AlamofireNetworking(),
            interceptor: apiInterceptor,
            networkMonitor: networkMonitor
        )

        self.ignoresResponseWhenEndpointsFailedFromUnauthorizedRequest = false

        debug {
            enableLogsInConsole()
        }
    }
}

extension ALGAPI {
    func setupNetworkBase(_ network: ALGAPI.Network) {
        base = apiInterceptor.setupNetworkBase(network)
    }
}

extension ALGAPI {
    enum Network: String {
        case testnet = "testnet"
        case mainnet = "mainnet"
    }
}
