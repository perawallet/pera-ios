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

//   IncominAsaTitleViewModel.swift

import Foundation
import MacaroonUIKit

protocol IncominASAListTitleViewModel: ViewModel {
    var primaryTitle: TextProvider? { get }
    var primaryTitleAccessory: Image?  { get }
    var secondaryTitle: TextProvider? { get }
    var secondSecondaryTitle: TextProvider? { get }
    var isCollectible: Bool? { get }
}

extension IncominASAListTitleViewModel where Self: Hashable {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(primaryTitle?.string)
        hasher.combine(secondaryTitle?.string)
        hasher.combine(secondSecondaryTitle?.string)
        hasher.combine(isCollectible)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.primaryTitle?.string == rhs.primaryTitle?.string &&
            lhs.secondaryTitle?.string == rhs.secondaryTitle?.string &&
            lhs.secondSecondaryTitle?.string == rhs.secondSecondaryTitle?.string &&
            lhs.isCollectible == rhs.isCollectible
    }
}
