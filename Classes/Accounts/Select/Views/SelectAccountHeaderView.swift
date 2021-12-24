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
//   SelectAccountHeaderView.swift


import Foundation
import UIKit
import MacaroonUIKit

final class SelectAccountHeaderView: View {
    private lazy var titleLabel = UILabel()

    func customize(_ theme: SelectAccountHeaderViewTheme) {
        addTitleLabel(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func bind(_ viewModel: SelectAccountHeaderViewModel) {
        titleLabel.text = viewModel.title
    }
}

extension SelectAccountHeaderView {
    private func addTitleLabel(_ theme: SelectAccountHeaderViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

class SelectAccountHeaderSupplementaryView: BaseSupplementaryView<SelectAccountHeaderView> {
    override func configureAppearance() {
        contextView.customize(SelectAccountHeaderViewTheme())
    }

    func bind(_ viewModel: SelectAccountHeaderViewModel) {
        contextView.bind(viewModel)
    }
}
