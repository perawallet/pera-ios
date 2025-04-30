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

//   SelectAddressViewControllerTheme.swift

import MacaroonUIKit

struct SelectAddressViewControllerTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let contentEdgeInsets: LayoutPaddings
    let title: TextStyle
    let spacingBetweenTitleAndDescription: LayoutMetric
    let spacingBetweenDescriptionAndHeader: LayoutMetric
    let headerHeight: LayoutMetric
    var headerTheme: SelectAddressListHeaderTheme
    let description: TextStyle
    let spacingListView: LayoutMetric
    let action: ButtonStyle
    let actionEdgeInsets: LayoutPaddings
    let actionContentEdgeInsets: LayoutPaddings

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contentEdgeInsets = (0, 24, 0, 24)
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .text(String(localized: "select-address-title").titleMedium(lineBreakMode: .byTruncatingTail))
        ]
        self.spacingBetweenTitleAndDescription = 16
        self.spacingBetweenDescriptionAndHeader = 34
        self.headerHeight = 24
        self.headerTheme = SelectAddressListHeaderTheme(family)
        self.description = [
            .textColor(Colors.Text.gray),
            .textOverflow(FittingText()),
        ]
        self.spacingListView = 28
        self.action = [
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Primary.text),
                .disabled(Colors.Button.Primary.disabledText)
            ]),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
        self.actionEdgeInsets = (16, 8, 16, 16)
        self.actionContentEdgeInsets = (8, 24, 12, 24)
    }
}

struct SelectAddressListHeaderTheme:
    StyleSheet,
    LayoutSheet {
    let background: ViewStyle
    let minimumHorizontalSpacing: LayoutMetric
    let info: TextStyle
    let infoMinWidthRatio: LayoutMetric
    let actionLayout: MacaroonUIKit.Button.Layout
    let selectAllAction: ButtonStyle
    let partialSelectionAction: ButtonStyle
    let unselectAllAction: ButtonStyle

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.minimumHorizontalSpacing = 8
        self.info = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main),
        ]
        self.infoMinWidthRatio = 0.5
        self.selectAllAction = [
            .title(String(localized: "title-select-all").bodyMedium(lineBreakMode: .byTruncatingTail)),
            .titleColor([ .normal(Colors.Link.primary) ]),
            .icon([ .normal("icon-checkbox-unselected") ])
        ]
        self.partialSelectionAction = [
            .title(String(localized: "title-select-all").bodyMedium(lineBreakMode: .byTruncatingTail)),
            .titleColor([ .normal(Colors.Link.primary) ]),
            .icon([ .normal("icon-checkbox-partial-selected") ])
        ]
        self.unselectAllAction = [
            .title(String(localized: "title-unselect-all").bodyMedium(lineBreakMode: .byTruncatingTail)),
            .titleColor([ .normal(Colors.Link.primary) ]),
            .icon([ .normal("icon-checkbox-selected") ])
        ]

        self.actionLayout = .imageAtRight(spacing: 12)
    }

    subscript (state: SelectAddressListHeaderItemState) -> ButtonStyle {
        switch state {
        case .selectAll: return selectAllAction
        case .partialSelection: return partialSelectionAction
        case .unselectAll: return unselectAllAction
        }
    }
}
