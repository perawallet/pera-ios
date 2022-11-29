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

//   DiscoverDappDetailNavigationViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

struct DiscoverDappDetailNavigationViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var subtitle: TextProvider?

    init(_ model: DiscoverDappParamaters) {
        bind(model)
    }
}

extension DiscoverDappDetailNavigationViewModel {
    mutating func bind(_ model: DiscoverDappParamaters) {
        bindTitle(model)
        bindSubtitle(model)
    }
}

extension DiscoverDappDetailNavigationViewModel {
    mutating func bindTitle(_ dappParameters: DiscoverDappParamaters) {
        let title = dappParameters.name

        self.title = title.bodyMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }

    mutating func bindSubtitle(_ dappParameters: DiscoverDappParamaters) {
        let subtitle = URL(string: dappParameters.url)?.presentationString

        self.subtitle = subtitle?.captionMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }
}
