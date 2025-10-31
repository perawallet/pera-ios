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

//   ASADetailViewController+PageItems.swift

import Foundation
import MacaroonUIKit
import UIKit

extension ASADetailViewController {
    struct HoldingsPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = PageBarItemID.holdings.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: PageBarItemID.holdings.title)
            self.screen = screen
        }
    }

    struct MarketsPageBarItem: PageBarItem {
        let id: String
        let barButtonItem: PageBarButtonItem
        let screen: UIViewController

        init(screen: UIViewController) {
            self.id = PageBarItemID.markets.rawValue
            self.barButtonItem = PrimaryPageBarButtonItem(title: PageBarItemID.markets.title)
            self.screen = screen
        }
    }

    enum PageBarItemID: String {
        case holdings
        case markets
        
        var title: String {
            switch self {
            case .holdings: String(localized: "title-holdings")
            case .markets: String(localized: "asset-detail-markets-title")
            }
        }
    }
}
