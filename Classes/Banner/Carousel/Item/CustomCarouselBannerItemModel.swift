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

//   CarouselBanner.swift

import UIKit
import Kingfisher

struct CustomCarouselBannerItemModel: Hashable {
    let id: Int
    let text: String
    let image: UIImageView
    let url: URL?
    let buttonUrlIsExternal: Bool
    
    init(apiModel: SpotBannerListItem.APIModel) {
        self.id = apiModel.id
        self.text = apiModel.text
        let imageView = UIImageView()
        imageView.kf.setImage(with: URL(string: apiModel.image))
        self.image = imageView
        self.url = URL(string: apiModel.url)
        self.buttonUrlIsExternal = apiModel.buttonUrlIsExternal
    }
}

enum CarouselBanner {
    case backup
    case stake
    case swap
    case algo
    case transfer
    case receive
    case discover
    case cards
    
    var title: String {
        switch self {
        case .backup:
            return String(localized: "account-not-backed-up-warning-title")
        case .stake:
            return String(localized: "transaction-option-list-staking-subtitle")
        case .swap:
            return String(localized: "title-carousel-banner-swap")
        case .algo:
            return String(localized: "title-carousel-banner-algo")
        case .transfer:
            return String(localized: "title-carousel-banner-transfer")
        case .receive:
            return String(localized: "title-carousel-banner-receive")
        case .discover:
            return String(localized: "title-carousel-banner-discover")
        case .cards:
            return String(localized: "title-carousel-banner-cards")
        }
    }
    
    var icon: UIImage {
        switch self {
        case .backup:
            return UIImage(named: "icon-backup-banner")!
        case .stake:
            return UIImage(named: "icon-stake-banner")!
        case .swap:
            return UIImage(named: "icon-swap-banner")!
        case .algo:
            return UIImage(named: "icon-algo-banner")!
        case .transfer:
            return UIImage(named: "icon-transfer-banner")!
        case .receive:
            return UIImage(named: "icon-receive-banner")!
        case .discover:
            return UIImage(named: "icon-discover-banner")!
        case .cards:
            return UIImage(named: "icon-cards-banner")!
        }
    }
    
    var iconBackground: UIColor {
        switch self {
        case .backup:
            return Colors.Helpers.negativeLighter.uiColor
        case .stake:
            return Colors.Wallet.wallet3IconGovernor.uiColor
        case .swap:
            return Colors.Wallet.wallet1.uiColor
        case .algo:
            return Colors.Wallet.wallet4.uiColor
        case .transfer:
            return Colors.Helpers.positiveLighter.uiColor
        case .receive:
            return Colors.Wallet.wallet5.uiColor
        case .discover:
            return Colors.Button.Secondary.focusBackground.uiColor
        case .cards:
            return Colors.Wallet.wallet2Icon.uiColor
        }
    }
    
    var showCloseButton: Bool {
        switch self {
        case .backup:
            return false
        default:
            return true
        }
    }
    
    var showNavigationButton: Bool {
        switch self {
        case .backup:
            return true
        default:
            return false
        }
    }
}
