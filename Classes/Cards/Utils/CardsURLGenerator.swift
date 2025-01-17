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

//   CardsURLGenerator.swift

import Foundation
import UIKit

final class CardsURLGenerator {
    static func generateURL(
        destination: CardsDestination,
        theme: UIUserInterfaceStyle,
        session: Session?,
        network: ALGAPI.Network
    ) -> URL? {
        switch destination {
        case .welcome:
            return generateURLForHome(
                theme: theme,
                session: session,
                network: network
            )
        case .other(path: let path):
            guard let path else { return nil }
            return generateURLForPath(
                path: path,
                theme: theme,
                session: session,
                network: network
            )
        }
    }

    private static func generateURLForHome(
        theme: UIUserInterfaceStyle,
        session: Session?,
        network: ALGAPI.Network
    ) -> URL? {
        var components = URLComponents(string: Environment.current.cardsBaseUrl(network: network))
        components?.queryItems = makeInHouseQueryItems(
            theme: theme,
            session: session
        )
        return components?.url
    }
    
    private static func generateURLForPath(
        path: String,
        theme: UIUserInterfaceStyle,
        session: Session?,
        network: ALGAPI.Network
    ) -> URL? {
        var components = URLComponents(string: Environment.current.cardsBaseUrl(network: network) + path)
        components?.queryItems = makeInHouseQueryItems(
            theme: theme,
            session: session
        )
        return components?.url
    }

    private static func makeInHouseQueryItems(
        theme: UIUserInterfaceStyle,
        session: Session?
    ) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        queryItems.append(.init(name: "version", value: "1"))
        queryItems.append(.init(name: "theme", value: theme.peraRawValue))
        queryItems.append(.init(name: "platform", value: "ios"))
        queryItems.append(.init(name: "currency", value: session?.preferredCurrencyID.localValue))
        if #available(iOS 16, *) {
            queryItems.append(.init(name: "language", value: Locale.preferred.language.languageCode?.identifier))
        } else {
            queryItems.append(.init(name: "language", value: Locale.preferred.languageCode))
        }
        if #available(iOS 16, *) {
            queryItems.append(.init(name: "region", value: Locale.current.region?.identifier))
        } else {
            queryItems.append(.init(name: "region", value: Locale.current.regionCode))
        }
        return queryItems
    }
}

enum CardsDestination {
    case welcome
    case other(path: String?)
}
