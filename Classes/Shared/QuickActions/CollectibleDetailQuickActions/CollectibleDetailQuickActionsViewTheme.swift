// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CollectibleDetailQuickActionsViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

struct CollectibleDetailQuickActionsViewTheme:
    StyleSheet,
    LayoutSheet {
    var spacingBetweenActions: LayoutMetric
    var actionWidth: LayoutMetric
    var actionSpacingBetweenIconAndTitle: LayoutMetric
    var sendAction: ButtonStyle
    var copyAction: ButtonStyle
    var saveAction: ButtonStyle

    init(_ family: LayoutFamily) {
        self.spacingBetweenActions = 16
        self.actionSpacingBetweenIconAndTitle = 12
        self.actionWidth = 64
        self.sendAction = [
            .icon(Self.makeActionIcon(icon: "send-dark-icon")),
            .title(Self.makeActionTitle(title: "quick-actions-send-title".localized))
        ]
        self.copyAction = [
            .icon(Self.makeActionIcon(icon: "copy-collectible-icon")),
            .title(Self.makeActionTitle(title: "title-copy".localized))
        ]
        self.saveAction = [
            .icon(Self.makeActionIcon(icon: "save-icon")),
            .title(Self.makeActionTitle(title: "title-save".localized))
        ]
    }
}

extension CollectibleDetailQuickActionsViewTheme {
    private static func makeActionIcon(icon: Image) -> StateImageGroup {
        return [ .normal(icon), .highlighted(icon) ]
    }
    
    private static func makeActionTitle(title: String) -> Text {
        var attributes = Typography.footnoteRegularAttributes(alignment: .center)
        attributes.insert(.textColor(Colors.Text.main))
        return TextSet(title.attributed(attributes))
    }
}
