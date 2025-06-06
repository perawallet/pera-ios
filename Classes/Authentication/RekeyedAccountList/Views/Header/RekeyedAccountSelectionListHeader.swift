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

//   RekeyedAccountSelectionListHeader.swift

import UIKit
import MacaroonUIKit

final class RekeyedAccountSelectionListHeader:
    CollectionSupplementaryView<UILabel>,
    ViewModelBindable {
    override class var contextPaddings: LayoutPaddings {
        return theme.contextEdgeInsets
    }

    static let theme = RekeyedAccountSelectionListHeaderTheme()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contextView.customizeAppearance(Self.theme.context)
    }

    func bindData(_ viewModel: RekeyedAccountSelectionListHeaderViewModel?) {
        if let title = viewModel?.title {
            title.load(in: contextView)
        } else {
            contextView.prepareForReuse()
        }
    }

    public static func calculatePreferredSize(
        _ viewModel: RekeyedAccountSelectionListHeaderViewModel?,
        for layoutSheet: LayoutSheet,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let contextWidth =
            width -
            theme.contextEdgeInsets.leading -
            theme.contextEdgeInsets.trailing
        let maxContextSize = CGSize((contextWidth, .greatestFiniteMagnitude))
        let contextSize = viewModel.title?.boundingSize(
            multiline: true,
            fittingSize: maxContextSize
        ) ?? .zero
        let preferredHeight =
            theme.contextEdgeInsets.top +
            contextSize.height +
            theme.contextEdgeInsets.bottom
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}
