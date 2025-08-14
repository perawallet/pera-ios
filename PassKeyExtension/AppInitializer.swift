// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import CoreData
import pera_wallet_core

// This class performs the same function as the AppDelegate in a normal app (i.e. initialize the world)
class AppInitializer {
    private var persistentContainer: NSPersistentContainer?
    private var session: Session?
    private var api: ALGAPI?
    private var sharedDataController: SharedDataController?
    private var walletConnectCoordinator: WalletConnectCoordinator?
    private var peraConnect: PeraConnect?
    private var analytics: ALGAnalytics?
    private var featureFlagService: FeatureFlagServicing?
    private var hdWalletService: HDWalletServicing?
    private var hdWalletStorage: HDWalletStorable?
    

    func initialize() {
        
        if CoreAppConfiguration.shared != nil {
            return
        }
        
        ALGAppTarget.setup()
        self.persistentContainer = NSPersistentContainer.createPersistentContainer(
            group: ALGAppTarget.current.app.appGroupIdentifier)
        self.featureFlagService = createFeatureFlagService()
        self.hdWalletService = createHDWalletService()
        self.hdWalletStorage = createHDWalletStorage()
        self.session = createSession()
        self.api = createAPI()
        self.analytics = createAnalytics()
        self.sharedDataController = createSharedDataController()
        self.walletConnectCoordinator = createWalletConnectCoordinator()
        self.peraConnect = createPeraConnect()
        
        
        let walletConnector = walletConnectCoordinator!.walletConnectProtocolResolver.walletConnectV1Protocol
        let config = CoreAppConfiguration(
            api: api!,
            session: session!,
            sharedDataController: sharedDataController!,
            walletConnector: walletConnector,
            analytics: analytics!,
            peraConnect: peraConnect!,
            featureFlagService: featureFlagService!,
            hdWalletService: hdWalletService!,
            hdWalletStorage: hdWalletStorage!
        )
        
        config.persistentContainer = self.persistentContainer
        CoreAppConfiguration.shared = config
    }
    
    private func createPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "algorand")
        let storeURL = URL.appGroupDBURL(for: ALGAppTarget.current.app.appGroupIdentifier, databaseName: "algorand")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores { storeDescription, error in
            if var url = storeDescription.url {
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true

                do {
                    try url.setResourceValues(resourceValues)
                } catch {
                }
            }

            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        return container
    }

    private func createSession() -> Session {
        let session = Session()
        Session.clearConfigurationCache()
        return session
    }

    private func createAPI() -> ALGAPI {
        ALGAPI(session: session!)
    }

    private func createSharedDataController() -> SharedDataController {
        let currency = CurrencyAPIProvider(session: session!, api: api!)
        let sharedDataController = SharedAPIDataController(
            target: ALGAppTarget.current,
            currency: currency,
            session: session!,
            storage: hdWalletStorage!,
            api: api!
        )
        return sharedDataController
    }
    
    private func createFeatureFlagService() -> FeatureFlagServicing {
        FeatureFlagService()
    }
    
    private func createHDWalletService() -> HDWalletService {
        HDWalletService()
    }
    
    private func createHDWalletStorage() -> HDWalletStorage {
        HDWalletStorage()
    }
    
    private func createAnalytics() -> ALGAnalytics {
        ALGAnalyticsCoordinator()
    }

    private func createPeraConnect() -> PeraConnect {
        ALGPeraConnect(walletConnectCoordinator: walletConnectCoordinator!)
    }
    
    private func createWalletConnectCoordinator() -> WalletConnectCoordinator {
        let resolver = ALGWalletConnectProtocolResolver(analytics: analytics!)
        return ALGWalletConnectCoordinator(walletConnectProtocolResolver: resolver)
    }
}

