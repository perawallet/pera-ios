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
//  AppEnvironment.swift

import Foundation
import UIKit

private enum AppTarget {
    case staging, prod
}

public class AppEnvironment {
    
    private static let instance = AppEnvironment()
    
    public static var current: AppEnvironment {
        instance
    }
    
    public let appID = "1459898525"
    
    public lazy var isTestNet = !ALGAppTarget.current.isProduction
    
    private var target: AppTarget {
        ALGAppTarget.current.isProduction ? .prod : .staging
    }
    
    public lazy var schema = "https"
    
    public lazy var algodToken: String = {
        guard let token = Bundle.main.infoDictionary?["ALGOD_TOKEN"] as? String else {
            return ""
        }
        return token
    }()

    public lazy var indexerToken: String = {
        guard let token = Bundle.main.infoDictionary?["INDEXER_TOKEN"] as? String else {
            return ""
        }
        return token
    }()

    public lazy var apiKey: String? = Bundle.main["API_KEY"]
    
    public lazy var testNetAlgodHost: String = {
        guard let host = Bundle.main.infoDictionary?["ALGOD_TESTNET_HOST"] as? String else {
            return ""
        }
        return host
    }()
    public lazy var testNetIndexerHost: String = {
        guard let host = Bundle.main.infoDictionary?["INDEXER_TESTNET_HOST"] as? String else {
            return ""
        }
        return host
    }()
    public private(set) lazy var testNetAlgodApi = "\(schema)://\(testNetAlgodHost)/v2"
    public private(set) lazy var testNetIndexerApi = "\(schema)://\(testNetIndexerHost)/v2"

    public lazy var mainNetAlgodHost: String = {
        guard let host = Bundle.main.infoDictionary?["ALGOD_MAINNET_HOST"] as? String else {
            return ""
        }
        return host
    }()
    public lazy var mainNetIndexerHost: String = {
        guard let host = Bundle.main.infoDictionary?["INDEXER_MAINNET_HOST"] as? String else {
            return ""
        }
        return host
    }()
    public private(set) lazy var mainNetAlgodApi = "\(schema)://\(mainNetAlgodHost)/v2"
    public private(set) lazy var mainNetIndexerApi = "\(schema)://\(mainNetIndexerHost)/v2"
    
    public let testNetARC59AppID: Int64 = 643020148
    public let mainNetARC59AppID: Int64 = 2449590623
    public let testNetARC59AppAddress = "YIIC6GF4DUJYZTYTZ5UEOAXONUUKZRDFOTV4EKSGD5E7BYE6EE3IVPYEDQ"
    public let mainNetARC59AppAddress = "EZRVNZFJGOUZC67FUMEC7ZMVP232TPICFTQCVZ6EQEIRRT3TIHSKZULRNI"
    
    public lazy var serverHost: String = {
        switch target {
        case .staging: testNetAlgodHost
        case .prod: mainNetAlgodHost
        }
    }()
    
    public lazy var serverApi: String = {
        let api = "\(schema)://\(serverHost)"
        return api
    }()

    public lazy var testNetStagingMobileHost: String = {
        guard let host = Bundle.main.infoDictionary?["MOBILE_API_STAGING_TESTNET_HOST"] as? String else {
            return ""
        }
        return host
    }()
    public lazy var testNetProductionMobileHost: String = {
        guard let host = Bundle.main.infoDictionary?["MOBILE_API_PROD_TESTNET_HOST"] as? String else {
            return ""
        }
        return host
    }()
    public lazy var testNetStagingMobileAPI = "\(schema)://\(testNetStagingMobileHost)"
    public lazy var testNetProductionMobileAPI = "\(schema)://\(testNetProductionMobileHost)"

    public lazy var mainNetStagingMobileHost: String = {
        guard let host = Bundle.main.infoDictionary?["MOBILE_API_STAGING_MAINNET_HOST"] as? String else {
            return ""
        }
        return host
    }()
    public lazy var mainNetProductionMobileHost: String = {
        guard let host = Bundle.main.infoDictionary?["MOBILE_API_PROD_MAINNET_HOST"] as? String else {
            return ""
        }
        return host
    }()
    public lazy var mainNetStagingMobileAPI = "\(schema)://\(mainNetStagingMobileHost)"
    public lazy var mainNetProductionMobileAPI = "\(schema)://\(mainNetProductionMobileHost)"

    public private(set) lazy var testNetMobileAPIV1: String = {
        switch target {
        case .staging: "\(testNetStagingMobileAPI)/v1/"
        case .prod: "\(testNetProductionMobileAPI)/v1/"
        }
    }()

    public private(set) lazy var mainNetMobileAPIV1: String = {
        switch target {
        case .staging: "\(mainNetStagingMobileAPI)/v1/"
        case .prod: "\(mainNetProductionMobileAPI)/v1/"
        }
    }()

    public private(set) lazy var testNetMobileAPIV2: String = {
        switch target {
        case .staging: "\(testNetStagingMobileAPI)/v2/"
        case .prod: "\(testNetProductionMobileAPI)/v2/"
        }
    }()

    public private(set) lazy var mainNetMobileAPIV2: String = {
        switch target {
        case .staging: "\(mainNetStagingMobileAPI)/v2/"
        case .prod: "\(mainNetProductionMobileAPI)/v2/"
        }
    }()
    
    public lazy var cardsMainNetBaseUrl: String = {
        switch target {
        case .staging: "https://cards-mobile-staging-mainnet.perawallet.app/"
        case .prod: "https://cards-mobile.perawallet.app/"
        }
    }()

    public lazy var cardsTestNetBaseUrl: String = {
        switch target {
        case .staging: "https://cards-mobile-staging-testnet.perawallet.app/"
        case .prod: "https://cards-mobile-staging.perawallet.app/"
        }
    }()
    
    public func cardsBaseUrl(network: ALGAPI.Network) -> String {
        switch network {
        case .testnet: cardsTestNetBaseUrl
        case .mainnet: cardsMainNetBaseUrl
        }
    }
    public func isCardsFeatureEnabled(for network: ALGAPI.Network) -> Bool {
        if network == .testnet && target == .prod {
            return false
        }
        
        return true
    }
    
    public lazy var stakingBaseUrl: String = {
        switch target {
        case .staging: "https://staking-mobile-staging.perawallet.app/"
        case .prod: "https://staking-mobile.perawallet.app/"
        }
    }()

    public lazy var discoverBaseUrl: String = {
        switch target {
        case .staging: "https://discover-mobile-staging.perawallet.app/"
        case .prod: "https://discover-mobile.perawallet.app/"
        }
    }()

    public lazy var discoverBrowserURL: String = {
        switch target {
        case .staging: "https://discover-mobile-staging.perawallet.app/main/browser"
        case .prod: "https://discover-mobile.perawallet.app/main/browser"
        }
    }()
    
    public lazy var discoverMarketURL: String = {
        switch target {
        case .staging: "https://discover-mobile-staging.perawallet.app/main/markets"
        case .prod: "https://discover-mobile.perawallet.app/main/markets"
        }
    }()
    
    public lazy var fundBaseUrl: String = {
        switch target {
        case .staging: "https://onramp-mobile-staging.perawallet.app/"
        case .prod: "https://onramp-mobile.perawallet.app/"
        }
    }()
}

public enum AlgorandWeb: String {
    case algorand = "https://www.algorand.com"
    case peraWebApp = "https://web.perawallet.app"
    case termsAndServices = "https://www.perawallet.app/terms-and-services/"
    case privacyPolicy = "https://www.perawallet.app/privacy-policy/"
    case support = "https://perawallet.app/support/"
    case dispenser = "https://lora.algokit.io/testnet/fund/"
    case backUpSupport = "https://perawallet.app/support/passphrase/"
    case recoverSupport = "https://perawallet.app/support/recover-account/"
    case watchAccountSupport = "https://perawallet.app/support/watch-accounts/"
    case ledgerSupport = "https://perawallet.app/support/ledger/"
    case transactionSupport = "https://perawallet.app/support/transactions/"
    case rewardsFAQ = "https://algorand.foundation/faq#participation-rewards"
    case governence = "https://governance.algorand.foundation/"
    case peraBlogLaunchAnnouncement = "https://perawallet.app/blog/launch-announcement/"
    case asaVerificationSupport = "https://explorer.perawallet.app/asa-verification/"
    case vestigeTermsOfService = "https://about.vestige.fi/disclaimer/terms-of-service"
    case tinymanSwapMain = "https://app.tinyman.org/#/swap?asset_in=0"
    case algorandSecureBackup = "https://perawallet.app/support/asb"
    case rekey = "https://perawallet.app/support/rekey/"
    case tinymanSwap = "https://perawallet.app/support/swap/"
    case tinymanSwapPriceImpact = "https://docs.tinyman.org/faq#what-is-a-price-impact"
    case hdWallet = "https://support.perawallet.app/support/hd-wallets/"
    case standard = "https://perawallet.app/support/create-new-account/"

    public var presentation: String {
        switch self {
        case .peraWebApp: "web.perawallet.app"
        case .support: "www.perawallet.app/support/"
        default: self.rawValue
        }
    }
    
    public static func == (lhs: AlgorandWeb, rhs: AlgorandWeb) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
    
    public enum PeraExplorer {
        case address(isMainnet: Bool, param: String)
        case asset(isMainnet: Bool, param: String)
        case group(isMainnet: Bool, param: String)
        
        public var link: URL? {
            switch self {
            case .address(let isMainnet, let param):
                isMainnet
                    ? URL(string: "https://explorer.perawallet.app/address/\(param)/")
                    : URL(string: "https://testnet.explorer.perawallet.app/address/\(param)/")
            case .asset(let isMainnet, let param):
                isMainnet
                    ? URL(string: "https://explorer.perawallet.app/asset/\(param)/")
                    : URL(string: "https://testnet.explorer.perawallet.app/asset/\(param)/")
            case .group(let isMainnet, let param):
                isMainnet
                    ? URL(string: "https://explorer.perawallet.app/tx-group/\(param)")
                    : URL(string: "https://testnet.explorer.perawallet.app/tx-group/\(param)")
            }
        }
    }
}

extension AlgorandWeb {
    public var link: URL? {
        URL(string: rawValue)
    }
}
