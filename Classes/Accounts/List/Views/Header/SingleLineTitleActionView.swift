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
//   SingleLineTitleActionView.swift

import UIKit
import MacaroonUIKit

final class SingleLineTitleActionView: View {
    private lazy var titleLabel = Label()
    private lazy var actionButton = Button()

    func customize(_ theme: SingleLineTitleActionViewTheme) {
        addActionButton(theme)
        addTitleLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) { }
    func prepareLayout(_ layoutSheet: LayoutSheet) { }
}

extension SingleLineTitleActionView {
    private func addActionButton(_ theme: SingleLineTitleActionViewTheme) {

    }
    
    private func addTitleLabel(_ theme: SingleLineTitleActionViewTheme) {

    }
}

extension SingleLineTitleActionView: ViewModelBindable {
    func bindData(_ viewModel: SingleLineTitleActionViewModel?) {

    }
}

class SingleLineTitleActionHeaderView: BaseSupplementaryView<SingleLineTitleActionView> {

    override func configureAppearance() {
        super.configureAppearance()
        contextView.customize(SingleLineTitleActionViewTheme())
    }

    func bind(_ viewModel: SingleLineTitleActionViewModel) {
        contextView.bindData(viewModel)
    }
}
