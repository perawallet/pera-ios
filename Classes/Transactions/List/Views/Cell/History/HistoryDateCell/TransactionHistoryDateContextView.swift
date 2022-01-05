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
//   TransactionHistoryDateContextView.swift

import MacaroonUIKit
import UIKit

final class TransactionHistoryDateContextView: View {
    private lazy var dateLabel = UILabel()

    func customize(_ theme: TransactionHistoryDateContextViewTheme) {
        addDateLabel(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
}

extension TransactionHistoryDateContextView {
    private func addDateLabel(_ theme: TransactionHistoryDateContextViewTheme) {
        dateLabel.customizeAppearance(theme.dateLabel)

        addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.paddings.top)
            $0.leading.trailing.equalToSuperview().inset(theme.paddings.leading)
            $0.bottom.equalToSuperview().inset(theme.paddings.bottom)
        }
    }
}

extension TransactionHistoryDateContextView: ViewModelBindable {
    func bindData(_ viewModel: TransactionHistoryDateContextViewModel?) {
        dateLabel.text = viewModel?.date
    }
}
