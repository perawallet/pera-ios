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

//   HomeChartsViewTheme.swift

import MacaroonUIKit

struct HomeChartsViewTheme:
    StyleSheet,
    LayoutSheet {
    var contentHeight: LayoutMetric
    var chartViewLeadingInset: LayoutMetric
    var chartViewTrailingInset: LayoutMetric

    init(_ family: LayoutFamily) {
        self.contentHeight = 172
        self.chartViewLeadingInset = -2
        self.chartViewTrailingInset = 16
    }
}
