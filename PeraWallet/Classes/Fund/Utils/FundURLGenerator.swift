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

//   FundURLGenerator.swift

import UIKit
import pera_wallet_core

final class FundURLGenerator {
    static func generateURL(
        theme: UIUserInterfaceStyle,
        session: Session?,
        path: String?,
        address: String?
    ) -> URL? {
        guard var components = URLComponents(string: AppEnvironment.current.fundBaseUrl) else { return nil }
        
        components.queryItems = makeInHouseQueryItems(
            theme: theme,
            session: session,
            address: address
        )
        
        guard let baseURL = components.url else { return nil }
        
        if PeraUserDefaults.enableTestXOSwapPage ?? false {
            return baseURL.appendingPathComponent("test")
        }
        
        guard let path else {
            return baseURL
        }
        
        return baseURL.appendingPathComponent(path)
    }

    private static func makeInHouseQueryItems(
        theme: UIUserInterfaceStyle,
        session: Session?,
        address: String?
    ) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "version", value: "1"),
            URLQueryItem(name: "theme", value: theme.peraRawValue),
            URLQueryItem(name: "platform", value: "ios"),
            URLQueryItem(name: "currency", value: session?.preferredCurrencyID.localValue),
            URLQueryItem(name: "language", value: Locale.preferred.language.languageCode?.identifier),
            URLQueryItem(name: "region", value: Locale.current.region?.identifier)
        ]
        if let address {
            queryItems.append(URLQueryItem(name: "address", value: address))
        }
        
        return queryItems
    }
}
