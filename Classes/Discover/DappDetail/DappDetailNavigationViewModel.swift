// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   DappDetailNavigationViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

struct DappDetailNavigationViewModel: BindableViewModel {
    private(set) var title: TextProvider?
    private(set) var subtitle: TextProvider?

    init<T>(_ model: T) {
        bind(model)
    }
}

extension DappDetailNavigationViewModel {
    mutating func bind<T>(_ model: T) {
        if let dappDetail = model as? DiscoverDappDetail {
            bindTitle(dappDetail)
            bindSubtitle(dappDetail)
            return
        }
    }
}

extension DappDetailNavigationViewModel {
    mutating func bindTitle(_ dappDetail: DiscoverDappDetail) {
        let title = dappDetail.name

        self.title = title.bodyMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }

    mutating func bindSubtitle(_ dappDetail: DiscoverDappDetail) {
        let subtitle = URL(string: dappDetail.url)?.presentationString

        self.subtitle = subtitle?.captionMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }
}
