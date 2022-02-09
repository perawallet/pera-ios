// Copyright 2022 Pera Wallet, LDA

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
//  TransactionHistoryFilterView.swift

import UIKit
import MacaroonUIKit

final class TransactionHistoryFilterView: View {
    weak var delegate: TransactionHistoryFilterViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var shareButton = UIButton()
    private(set) lazy var filterButton = UIButton()

    func setListeners() {
        filterButton.addTarget(self, action: #selector(notifyDelegateToOpenFilterOptions), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareHistory), for: .touchUpInside)
    }

    func customize(_ theme: TransactionHistoryHeaderViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addShareButton(theme)
        addFilterButton(theme)
        addTitleLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension TransactionHistoryFilterView {
    @objc
    private func notifyDelegateToOpenFilterOptions() {
        delegate?.transactionHistoryFilterViewDidOpenFilterOptions(self)
    }
    
    @objc
    private func notifyDelegateToShareHistory() {
        delegate?.transactionHistoryFilterViewDidShareHistory(self)
    }
}

extension TransactionHistoryFilterView {
    private func addShareButton(_ theme: TransactionHistoryHeaderViewTheme) {
        shareButton.customizeAppearance(theme.shareButton)

        addSubview(shareButton)
        shareButton.snp.makeConstraints {
            $0.fitToSize(theme.buttonSize)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func addFilterButton(_ theme: TransactionHistoryHeaderViewTheme) {
        addSubview(filterButton)
        filterButton.snp.makeConstraints {
            $0.fitToSize(theme.buttonSize)
            $0.trailing.equalTo(shareButton.snp.leading).offset(-theme.buttonInset)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func addTitleLabel(_ theme: TransactionHistoryHeaderViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.trailing.equalTo(filterButton.snp.leading).offset(-theme.horizontalInset)
            $0.centerY.equalToSuperview()
        }
    }
}

extension TransactionHistoryFilterView: ViewModelBindable {
    func bindData(_ viewModel: TransactionHistoryFilterViewModel?) {
        titleLabel.text = viewModel?.title
        filterButton.setImage(viewModel?.image, for: .normal)
    }
}

protocol TransactionHistoryFilterViewDelegate: AnyObject {
    func transactionHistoryFilterViewDidOpenFilterOptions(_ transactionHistoryFilterView: TransactionHistoryFilterView)
    func transactionHistoryFilterViewDidShareHistory(_ transactionHistoryFilterView: TransactionHistoryFilterView)
}
