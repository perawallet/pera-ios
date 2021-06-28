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
//   WCGroupTransactionHeaderView.swift

import UIKit

class WCGroupTransactionHeaderView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCGroupTransactionHeaderViewDelegate?

    private lazy var dappMessageView = WCTransactionDappMessageView()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.secondary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()

    override func prepareLayout() {
        setupDappMessageViewLayout()
        setupTitleLabelLayout()
    }

    override func setListeners() {
        dappMessageView.addTarget(self, action: #selector(notifyDelegateToOpenLongDappMessage), for: .touchUpInside)
    }
}

extension WCGroupTransactionHeaderView {
    private func setupDappMessageViewLayout() {
        addSubview(dappMessageView)

        dappMessageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.centerX.equalToSuperview()
        }
    }

    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.titleLeadingInset)
            make.top.equalTo(dappMessageView.snp.bottom).offset(layout.current.titleTopInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension WCGroupTransactionHeaderView {
    @objc
    private func notifyDelegateToOpenLongDappMessage() {
        delegate?.wcGroupTransactionHeaderViewDidOpenLongMessageView(self)
    }
}

extension WCGroupTransactionHeaderView {
    func bind(_ viewModel: WCGroupTransactionHeaderViewModel) {
        if let transactionDappMessageViewModel = viewModel.transactionDappMessageViewModel {
            dappMessageView.bind(transactionDappMessageViewModel)
        }

        titleLabel.text = viewModel.title
    }
}

extension WCGroupTransactionHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 8.0
        let horizontalInset: CGFloat = 20.0
        let titleTopInset: CGFloat = 40.0
        let titleLeadingInset: CGFloat = 24.0
    }
}

protocol WCGroupTransactionHeaderViewDelegate: AnyObject {
    func wcGroupTransactionHeaderViewDidOpenLongMessageView(_ wcGroupTransactionHeaderView: WCGroupTransactionHeaderView)
}
