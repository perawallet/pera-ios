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

//   CollectibleListViewControllerTheme.swift

import MacaroonUIKit

protocol CollectibleListViewControllerTheme:
    StyleSheet,
    LayoutSheet {
    var listContentBottomInset: LayoutMetric { get }
}

struct CollectibleListViewControllerCommonTheme:
    CollectibleListViewControllerTheme {
    let listContentBottomInset: LayoutMetric

    init(
        _ family: LayoutFamily
    ) {
        listContentBottomInset = .zero
    }
}

struct CollectibleListViewControllerAccountDetailTheme:
    CollectibleListViewControllerTheme {
    let listContentBottomInset: LayoutMetric

    init(
        _ family: LayoutFamily,
        isWatchAccount: Bool
    ) {
        if isWatchAccount {
            listContentBottomInset = .zero
        } else {
            listContentBottomInset = 88
        }
    }

    init(
        _ family: LayoutFamily
    ) {
        self.init(family, isWatchAccount: false)
    }
}
