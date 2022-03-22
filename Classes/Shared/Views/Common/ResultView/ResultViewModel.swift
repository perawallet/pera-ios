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

//
//   ResultViewModel.swift

import Foundation
import MacaroonUIKit

protocol ResultViewModel: ViewModel {
    var icon: Image? { get }
    var title: EditText? { get }
    var body: EditText? { get }
}

extension ResultViewModel where Self: Hashable {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(title)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.title == rhs.title &&
        lhs.body == rhs.body
    }
}
