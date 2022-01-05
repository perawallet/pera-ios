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
//   WCMainTransactionScreen+Theme.swift

import Foundation
import MacaroonUIKit
import MacaroonBottomOverlay

struct WCMainTransactionScreenStyleSheet: StyleSheet, BottomDetailOverlayContainerStyleSheet, BottomScrollOverlayContainerStyleSheet {
    var detailOverlay: BottomOverlayViewStyleSheet
    var scrollOverlay: BottomOverlayViewStyleSheet

    init() {
        detailOverlay = BottomOverlayCommonStyleSheet()
        scrollOverlay = BottomOverlayCommonStyleSheet()
    }
}

struct WCMainTransactionScreenLayoutSheet: LayoutSheet, BottomDetailOverlayContainerLayoutSheet, BottomScrollOverlayContainerLayoutSheet {
    var scrollOverlay: BottomOverlayViewLayoutSheet
    var scrollOverlayHorizontalPaddings: LayoutHorizontalPaddings
    private var scrollOverlayOffsetsPerPosition: [BottomScrollOverlayPosition: LayoutMetric]

    subscript(pos: BottomScrollOverlayPosition) -> LayoutMetric {
        get { scrollOverlayOffsetsPerPosition[pos] ?? .noMetric }
        set { scrollOverlayOffsetsPerPosition[pos] = newValue }
    }

    var detailOverlay: BottomOverlayViewLayoutSheet
    var detailOverlayHorizontalPaddings: LayoutHorizontalPaddings

    init(_ family: LayoutFamily) {
        scrollOverlay = BottomOverlayCommonLayoutSheet(family)
        scrollOverlayHorizontalPaddings = (0, 0)
        scrollOverlayOffsetsPerPosition = [:]
        detailOverlay = BottomOverlayCommonLayoutSheet(family)
        detailOverlayHorizontalPaddings = (0, 0)
    }
}
extension WCMainTransactionScreenLayoutSheet {
    mutating func calculateScrollOverlayOffsetsAtEachPosition(
        in screen: WCMainTransactionScreen
    ) {
        let minScrollOverlayOffset: LayoutMetric = 24
        let scrollOverlayHeight = screen.view.bounds.height - minScrollOverlayOffset

        self[.top] = minScrollOverlayOffset
        self[.mid] = (scrollOverlayHeight * 0.58).ceil()
        self[.bottom] = (scrollOverlayHeight * 0.92).ceil()
    }
}
