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

//   WCSessionRequestedPermissionItemCell.swift

import UIKit
import MacaroonUIKit

final class WCSessionRequestedPermissionItemCell:
    CollectionCell<WCSessionRequestedPermissionItemView>,
    ViewModelBindable {
    override static var contextPaddings: LayoutPaddings {
        return theme.contextEdgeInsets
    }

    static let theme = WCSessionRequestedPermissionItemCellTheme()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contextView.customize(Self.theme.context)
    }
    
    func bindData(_ viewModel: WCSessionRequestedPermissionViewModel?) {
        contextView.bindData(viewModel)
    }

    public static func calculatePreferredSize(
        _ viewModel: WCSessionRequestedPermissionViewModel?,
        for layoutSheet: LayoutSheet,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let contextWidth =
        width -
        contextPaddings.leading -
        contextPaddings.trailing

        let maxContextSize = CGSize((contextWidth, .greatestFiniteMagnitude))

        let titleSize = viewModel.title.boundingSize(
            multiline: false,
            fittingSize: maxContextSize
        )

        let rowsHeight = viewModel.rows.reduce(0) {
            $0 + $1.boundingSize(multiline: false, fittingSize: maxContextSize).height + theme.context.spacingBetweenTitleAndRows
        }

        let contextSize = titleSize.height + rowsHeight

        let preferredHeight =
        contextPaddings.top +
        Self.theme.context.contentEdgeInsets.top +
        contextSize +
        Self.theme.context.contentEdgeInsets.bottom +
        contextPaddings.bottom
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}
