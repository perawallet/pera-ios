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
//  AppConfiguration.swift

import Foundation
import CoreData

open class CoreAppConfiguration {
    public let api: ALGAPI
    public let session: Session
    public let sharedDataController: SharedDataController
    public let walletConnector: WalletConnectV1Protocol
    public let analytics: ALGAnalytics
    public let peraConnect: PeraConnect
    public let featureFlagService: FeatureFlagServicing
    public let hdWalletService: HDWalletServicing
    public let hdWalletStorage: HDWalletStorable
    public var persistentContainer: NSPersistentContainer?
    public var wcDelegate: WalletConnectRequestHandlerDelegate?
    
    public static var shared: CoreAppConfiguration?

    public init(
        api: ALGAPI,
        session: Session,
        sharedDataController: SharedDataController,
        walletConnector: WalletConnectV1Protocol,
        analytics: ALGAnalytics,
        peraConnect: PeraConnect,
        featureFlagService: FeatureFlagServicing,
        hdWalletService: HDWalletServicing,
        hdWalletStorage: HDWalletStorable
    ) {
        self.api = api
        self.session = session
        self.sharedDataController = sharedDataController
        self.walletConnector = walletConnector
        self.analytics = analytics
        self.peraConnect = peraConnect
        self.featureFlagService = featureFlagService
        self.hdWalletService = hdWalletService
        self.hdWalletStorage = hdWalletStorage
    }
    
    func clearAll() {
        self.session.clear(.keychain)
        self.session.clear(.defaults)
    }
}
