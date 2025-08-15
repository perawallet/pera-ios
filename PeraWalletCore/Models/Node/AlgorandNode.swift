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

//
//  AlgorandNode.swift

import Foundation

public struct AlgorandNode {
    public let algodAddress: String
    public let indexerAddress: String
    public let algodToken: String
    public let indexerToken: String
    public let name: String
    public let network: ALGAPI.Network
}

public let mainNetNode = AlgorandNode(
    algodAddress: AppEnvironment.current.mainNetAlgodHost,
    indexerAddress: AppEnvironment.current.mainNetAlgodHost,
    algodToken: AppEnvironment.current.algodToken,
    indexerToken: AppEnvironment.current.indexerToken,
    name: String(localized: "node-settings-default-node-name"),
    network: .mainnet
)

public let testNetNode = AlgorandNode(
    algodAddress: AppEnvironment.current.testNetAlgodHost,
    indexerAddress: AppEnvironment.current.testNetIndexerHost,
    algodToken: AppEnvironment.current.algodToken,
    indexerToken: AppEnvironment.current.indexerToken,
    name: String(localized: "node-settings-default-test-node-name"),
    network: .testnet
)
