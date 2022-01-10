// Copyright 2019 Algorand, Inc.

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
//   AccountPortfolioListLayout.swift

import Foundation
import UIKit

final class AccountPortfolioListLayout: NSObject {
    private lazy var theme = Theme()
    lazy var handlers = Handlers()

    private let session: Session

    init(session: Session) {
        self.session = session
        super.init()
    }
}

extension AccountPortfolioListLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let section = AccountPortfolioSection(rawValue: indexPath.section) else {
            return .zero
        }

        switch section {
        case .portfolio:
            return CGSize(theme.portfolioItemSize)
        case .announcement:
            return .zero
        case .standardAccount,
                .watchAccount:
            return CGSize(theme.accountItemSize)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard let section = AccountPortfolioSection(rawValue: section) else {
            return .zero
        }

        switch section {
        case .portfolio,
                .announcement:
            return .zero
        case .standardAccount,
                .watchAccount:
            return CGSize(theme.listHeaderSize)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = AccountPortfolioSection(rawValue: indexPath.section),
              section == .standardAccount || section == .watchAccount,
            let account = session.accounts[safe: indexPath.item] else {
                return
        }

        handlers.didSelectAccount?(account)
    }
}

extension AccountPortfolioListLayout {
    struct Handlers {
        var didSelectAccount: ((Account) -> Void)?
    }
}
