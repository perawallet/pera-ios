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

//   StakingURLGenerator.swift

import Foundation
import UIKit
import pera_wallet_core

final class StakingURLGenerator {
    static func generateURL(
        destination: StakingDestination,
        theme: UIUserInterfaceStyle,
        session: Session?,
        hideBackButton: Bool
    ) -> URL? {
        switch destination {
        case .list:
            return generateURLForList(
                theme: theme,
                session: session,
                hideBackButton: hideBackButton
            )
        }
    }

    private static func generateURLForList(
        theme: UIUserInterfaceStyle,
        session: Session?,
        hideBackButton: Bool
    ) -> URL? {
        var components = URLComponents(string: AppEnvironment.current.stakingBaseUrl)
        components?.queryItems = makeInHouseQueryItems(
            theme: theme,
            session: session,
            hideBackButton: hideBackButton
        )
        return components?.url
    }

    private static func makeInHouseQueryItems(
        theme: UIUserInterfaceStyle,
        session: Session?,
        hideBackButton: Bool
    ) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        queryItems.append(.init(name: "version", value: "1"))
        queryItems.append(.init(name: "theme", value: theme.peraRawValue))
        queryItems.append(.init(name: "platform", value: "ios"))
        queryItems.append(.init(name: "currency", value: session?.preferredCurrencyID.localValue))
        queryItems.append(.init(name: "currency", value: session?.preferredCurrencyID.localValue))
        queryItems.append(.init(name: "language", value: Locale.preferred.language.languageCode?.identifier))
        queryItems.append(.init(name: "region", value: Locale.current.region?.identifier))
        return queryItems
    }
}

enum StakingDestination {
    case list
}
