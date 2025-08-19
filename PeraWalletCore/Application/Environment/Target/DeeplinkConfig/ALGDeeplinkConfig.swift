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

//   ALGDeeplinkConfig.swift

import Foundation

public final class ALGDeeplinkConfig:
    DeeplinkConfig,
    Decodable {
    public let qr: DeeplinkSourceGroupConfig
    public let walletConnect: DeeplinkSourceGroupConfig
    public let moonpay: DeeplinkSourceConfig
    
    private enum CodingKeys:
        String,
        CodingKey {
        case qr
        case walletConnect
        case moonpay
    }
    
    public init(
        qr: DeeplinkSourceGroupConfig,
        walletConnect: DeeplinkSourceGroupConfig,
        moonpay: DeeplinkSourceConfig
    ) {
        self.qr = qr
        self.walletConnect = walletConnect
        self.moonpay = moonpay
    }
    
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.qr = try container.decode(
            ALGDeeplinkSourceGroupConfig.self,
            forKey: .qr
        )
        self.walletConnect = try container.decode(
            ALGDeeplinkSourceGroupConfig.self,
            forKey: .walletConnect
        )
        self.moonpay = try container.decode(
            ALGDeeplinkSourceConfig.self,
            forKey: .moonpay
        )
    }
}

public final class ALGDeeplinkSourceGroupConfig:
    DeeplinkSourceGroupConfig,
    Decodable {
    public let acceptedSchemes: [String]
    public let preferredScheme: String
    
    public init(
        acceptedSchemes: [String],
        preferredScheme: String
    ) {
        self.acceptedSchemes = acceptedSchemes
        self.preferredScheme = preferredScheme
    }
}

public final class ALGDeeplinkSourceConfig:
    DeeplinkSourceConfig,
    Decodable {
    public let scheme: String
    
    public init(
        scheme: String
    ) {
        self.scheme = scheme
    }
}
