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

//   MenuOption.swift

import UIKit

enum MenuOption {
    case cards(state: MenuCardState)
    case nfts(withThumbnails: [URL])
    case transfer
    case buyAlgo
    case receive
    case inviteFriends
    
    var title: String {
        switch self {
        case .cards:
            return String(localized: "title-cards")
        case .nfts:
            return String(localized: "title-collectibles")
        case .transfer:
            return String(localized: "collectible-send-action")
        case .buyAlgo:
            return String(localized: "quick-actions-buy-algo-title")
        case .receive:
            return String(localized: "quick-actions-receive-title")
        case .inviteFriends:
            return String(localized: "title-invite-friends")
        }
    }
    
    var description: String {
        switch self {
        case .cards(state: let state):
            switch state {
            case .inactive, .active:
                return String(localized: "menu-card-banner-description")
            case .addedToWailist:
                return .empty
            }
        default:
            fatalError("Shouldn't enter here")
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .cards:
            return UIImage(named: "icon-menu-cards")
        case .nfts:
            return UIImage(named: "tabbar-icon-collectibles-selected")
        case .transfer:
            return UIImage(named: "icon-menu-transfer")
        case .buyAlgo:
            return UIImage(named: "icon-menu-buy-algo")
        case .receive:
            return UIImage(named: "icon-menu-receive")
        case .inviteFriends:
            return UIImage(named: "icon-menu-invite")
        }
    }
    
    var showNewLabel: Bool {
        switch self {
        case .transfer:
            return true
        default:
            return false
        }
    }
}

enum MenuCardState {
    case inactive
    case active
    case addedToWailist
}
