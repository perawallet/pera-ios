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

//   SortAccountListTitleSupplementaryHeader.swift

import UIKit

final class SortAccountListTitleSupplementaryHeader:
    BaseSupplementaryView<TitleView> {
    static let theme: TitleViewTheme = {
        var theme = TitleViewTheme()
        theme.paddings = (20, 24, 12, 24)
        return theme
    }()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        contextView.customize(Self.theme)
    }

    func bindData(
        _ viewModel: TitleViewModel
    ) {
        contextView.bindData(viewModel)
    }
}
