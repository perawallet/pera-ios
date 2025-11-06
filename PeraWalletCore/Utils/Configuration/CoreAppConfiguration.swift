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

// This class performs the same function as the AppDelegate in a normal app (i.e. initialize the world)
extension CoreAppConfiguration {
    public static func initialize() throws {
        if CoreAppConfiguration.shared != nil {
            return
        }
        
        ALGAppTarget.setup()
        let persistentContainer: NSPersistentContainer = try NSPersistentContainer.makePersistentContainer(
            group: ALGAppTarget.current.appGroupIdentifier)
        let featureFlagService = makeFeatureFlagService()
        let hdWalletService = makeHDWalletService()
        let hdWalletStorage = makeHDWalletStorage()
        let session = makeSession()
        let analytics = makeAnalytics()
        let api = makeAPI(session: session, analytics: analytics, featureFlagService: featureFlagService)
        let sharedDataController = makeSharedDataController(session: session, api: api, hdWalletStorage: hdWalletStorage)
        let walletConnectCoordinator = makeWalletConnectCoordinator(analytics: analytics)
        let peraConnect = makePeraConnect(walletConnectCoordinator: walletConnectCoordinator)
        
        let walletConnector = walletConnectCoordinator.walletConnectProtocolResolver.walletConnectV1Protocol
        let config = CoreAppConfiguration(
            api: api,
            session: session,
            sharedDataController: sharedDataController,
            walletConnector: walletConnector,
            analytics: analytics,
            peraConnect: peraConnect,
            featureFlagService: featureFlagService,
            hdWalletService: hdWalletService,
            hdWalletStorage: hdWalletStorage
        )
        
        config.persistentContainer = persistentContainer
        CoreAppConfiguration.shared = config
    }

    private static func makeSession() -> Session {
        let session = Session()
        Session.clearConfigurationCache()
        return session
    }

    private static func makeAPI(session: Session, analytics: ALGAnalytics, featureFlagService: FeatureFlagServicing) -> ALGAPI {
        ALGAPI(session: session, analytics: analytics, featureFlagService: featureFlagService)
    }

    private static func makeSharedDataController(session: Session, api: ALGAPI, hdWalletStorage: HDWalletStorage) -> SharedDataController {
        let currency = CurrencyAPIProvider(session: session, api: api)
        let sharedDataController = SharedAPIDataController(
            target: ALGAppTarget.current,
            currency: currency,
            session: session,
            storage: hdWalletStorage,
            api: api
        )
        return sharedDataController
    }
    
    private static func makeFeatureFlagService() -> FeatureFlagServicing {
        FeatureFlagService()
    }
    
    private static func makeHDWalletService() -> HDWalletService {
        HDWalletService()
    }
    
    private static func makeHDWalletStorage() -> HDWalletStorage {
        HDWalletStorage()
    }
    
    private static func makeAnalytics() -> ALGAnalytics {
        ALGAnalyticsCoordinator()
    }

    private static func makePeraConnect(walletConnectCoordinator: WalletConnectCoordinator) -> PeraConnect {
        ALGPeraConnect(walletConnectCoordinator: walletConnectCoordinator)
    }
    
    private static func makeWalletConnectCoordinator(analytics: ALGAnalytics) -> WalletConnectCoordinator {
        let resolver = ALGWalletConnectProtocolResolver(analytics: analytics)
        return ALGWalletConnectCoordinator(walletConnectProtocolResolver: resolver)
    }
}

