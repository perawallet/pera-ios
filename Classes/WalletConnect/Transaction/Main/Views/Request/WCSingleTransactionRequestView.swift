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
//   WCSingleTransactionRequestView.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonBottomOverlay

protocol WCSingleTransactionRequestViewDelegate: AnyObject {
    func wcSingleTransactionRequestViewDidTapCancel(_ requestView: WCSingleTransactionRequestView)
    func wcSingleTransactionRequestViewDidTapConfirm(_ requestView: WCSingleTransactionRequestView)
    func wcSingleTransactionRequestViewDidTapShowTransaction(_ requestView: WCSingleTransactionRequestView)
}

final class WCSingleTransactionRequestView: BaseView {
    private lazy var confirmButton = Button()
    private lazy var cancelButton = Button()
    private(set) lazy var bottomView = WCSingleTransactionRequestBottomView()
    private(set) lazy var middleView = WCSingleTransactionRequestMiddleView()

    private lazy var theme = WCSingleTransactionRequestViewTheme()

    weak var delegate: WCSingleTransactionRequestViewDelegate?

    override func configureAppearance() {
        super.configureAppearance()

        backgroundColor = theme.backgroundColor.uiColor
        bottomView.backgroundColor = theme.backgroundColor.uiColor
        middleView.backgroundColor = theme.backgroundColor.uiColor

        confirmButton.customize(theme.confirmButton)
        confirmButton.setTitle("title-confirm".localized, for: .normal)
        cancelButton.customize(theme.cancelButton)
        cancelButton.setTitle("title-cancel".localized, for: .normal)
    }

    override func linkInteractors() {
        super.linkInteractors()

        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        bottomView.showTransactionDetailsButton.addTarget(self, action: #selector(didTapShowTransaction), for: .touchUpInside)
    }

    override func prepareLayout() {
        super.prepareLayout()

        addButtons()
        addBottomView()
        addMiddleView()
    }

    func bind(_ viewModel: WCSingleTransactionRequestViewModel?) {
        bottomView.bind(viewModel?.bottomView)
        middleView.bind(viewModel?.middleView)
    }
}

extension WCSingleTransactionRequestView {
    @objc
    private func didTapCancel() {
        delegate?.wcSingleTransactionRequestViewDidTapCancel(self)
    }

    @objc
    private func didTapConfirm() {
        delegate?.wcSingleTransactionRequestViewDidTapConfirm(self)
    }

    @objc
    private func didTapShowTransaction() {
        delegate?.wcSingleTransactionRequestViewDidTapShowTransaction(self)
    }
}

extension WCSingleTransactionRequestView {
    private func addButtons() {
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(theme.horizontalPadding)
            make.height.equalTo(theme.buttonHeight)
        }

        addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalTo(cancelButton.snp.trailing).offset(theme.buttonPadding)
            make.trailing.equalToSuperview().inset(theme.horizontalPadding)
            make.height.equalTo(cancelButton)
            make.width.equalTo(cancelButton).multipliedBy(theme.confirmButtonWidthMultiplier)
        }
    }

    private func addBottomView() {
        addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.bottom.equalTo(confirmButton.snp.top).offset(theme.bottomViewBottomOffset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(theme.bottomHeight)
        }
    }

    private func addMiddleView() {
        addSubview(middleView)
        middleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }

        middleView.addSeparator(theme.separator)
    }
}
