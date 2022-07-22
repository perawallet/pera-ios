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

//   PrimaryListItemViewModel.swift

import Foundation
import MacaroonUIKit

protocol PrimaryListItemViewModel: ViewModel {
    var imageViewModel: PrimaryImageViewModel?  { get }
    var primaryTitleViewModel: PrimaryTitleViewModel? { get }
    var secondaryTitleViewModel: PrimaryTitleViewModel? { get }
}

extension PrimaryListItemViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(imageViewModel?.imageSource?.url)
        hasher.combine(primaryTitleViewModel?.title)
        hasher.combine(primaryTitleViewModel?.subtitle)
        hasher.combine(secondaryTitleViewModel?.title)
        hasher.combine(secondaryTitleViewModel?.subtitle)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.imageViewModel?.imageSource?.url == rhs.imageViewModel?.imageSource?.url &&
        lhs.primaryTitleViewModel?.title == rhs.primaryTitleViewModel?.title &&
        lhs.primaryTitleViewModel?.subtitle == rhs.primaryTitleViewModel?.subtitle &&
        lhs.secondaryTitleViewModel?.title == rhs.secondaryTitleViewModel?.title &&
        lhs.secondaryTitleViewModel?.subtitle == rhs.secondaryTitleViewModel?.subtitle
    }
}
