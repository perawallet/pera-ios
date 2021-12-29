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
//  TransactionDetailView.swift

import UIKit
import MacaroonUIKit

final class TransactionDetailView: View {    
    weak var delegate: TransactionDetailViewDelegate?

    private lazy var verticalStackView = UIStackView()
    private(set) lazy var statusView = TransactionStatusInformationView()
    private(set) lazy var amountView = TransactionAmountInformationView()
    private(set) lazy var closeAmountView = TransactionAmountInformationView()
    private(set) lazy var rewardView = TransactionAmountInformationView()
    private(set) lazy var userView = TransactionTextInformationView()
    private(set) lazy var opponentView = TransactionContactInformationView()
    private(set) lazy var closeToView = TransactionTextInformationView()
    private(set) lazy var feeView = TransactionAmountInformationView()
    private lazy var dateView = TransactionTextInformationView()
    private(set) lazy var roundView = TransactionTextInformationView()
    private(set) lazy var idView = TransactionTextInformationView()
    private(set) lazy var noteView = TransactionTextInformationView()
    private lazy var openInAlgoExplorerButton = UIButton()
    private lazy var openInGoalSeekerButton = UIButton()

    private let transactionType: TransactionType
    
    init(transactionType: TransactionType) {
        self.transactionType = transactionType
        super.init(frame: .zero)

        customize(TransactionDetailViewTheme())
        linkInteractors()
    }
    
    func linkInteractors() {
        opponentView.delegate = self
        opponentView.linkInteractors()

        closeToView.addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(notifyDelegateToCopyCloseToView)
            )
        )
        opponentView.addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(notifyDelegateToCopyOpponentView)
            )
        )
        noteView.addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(notifyDelegateToCopyNoteView)
            )
        )
        idView.addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(notifyDelegateToCopyTransactionID)
            )
        )
        openInAlgoExplorerButton.addTarget(self, action: #selector(notifyDelegateToOpenAlgoExplorer), for: .touchUpInside)
        openInGoalSeekerButton.addTarget(self, action: #selector(notifyDelegateToOpenGoalSeaker), for: .touchUpInside)
    }
    
    func customize(_ theme: TransactionDetailViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        addVerticalStackView(theme)
        addAmountView(theme)
        addCloseAmountView(theme)
        addRewardView(theme)
        addStatusView(theme)

        if transactionType == .received {
            addOpponentView(theme)
            addUserView(theme)
        } else {
            addUserView(theme)
            addOpponentView(theme)
        }

        addCloseToView(theme)
        addFeeView(theme)
        addDateView(theme)
        addRoundView(theme)
        addIdView(theme)
        addNoteView(theme)
        addOpenInAlgoExplorerButton(theme)
        addOpenInGoalSeekerButton(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
}

extension TransactionDetailView {
    private func addVerticalStackView(_ theme: TransactionDetailViewTheme) {
        verticalStackView.axis = .vertical
        verticalStackView.spacing = theme.verticalStackViewSpacing
        addSubview(verticalStackView)

        verticalStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.verticalStackViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    private func addAmountView(_ theme: TransactionDetailViewTheme) {
        amountView.customize(TransactionAmountInformationViewTheme(transactionAmountViewTheme: TransactionAmountViewBiggerTheme()))
        amountView.setTitle("transaction-detail-amount".localized)

        verticalStackView.addArrangedSubview(amountView)
    }
    
    private func addCloseAmountView(_ theme: TransactionDetailViewTheme) {
        closeAmountView.customize(theme.commonTransactionAmountInformationViewTheme)
        closeAmountView.setTitle("transaction-detail-close-amount".localized)

        verticalStackView.addArrangedSubview(closeAmountView)
    }

    private func addStatusView(_ theme: TransactionDetailViewTheme) {
        statusView.customize(theme.transactionStatusInformationViewTheme)
        statusView.setTitle("transaction-detail-status".localized)

        verticalStackView.addArrangedSubview(statusView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: statusView)
        statusView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }

    private func addRewardView(_ theme: TransactionDetailViewTheme) {
        rewardView.customize(theme.commonTransactionAmountInformationViewTheme)
        rewardView.setTitle("transaction-detail-reward".localized)

        verticalStackView.addArrangedSubview(rewardView)
    }
    
    private func addUserView(_ theme: TransactionDetailViewTheme) {
        userView.customize(theme.transactionTextInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(userView)
    }
    
    private func addOpponentView(_ theme: TransactionDetailViewTheme) {
        opponentView.customize(theme.transactionContactInformationViewTheme)
        opponentView.isUserInteractionEnabled = true

        verticalStackView.addArrangedSubview(opponentView)
    }
    
    private func addCloseToView(_ theme: TransactionDetailViewTheme) {
        closeToView.customize(theme.transactionTextInformationViewCommonTheme)
        closeToView.setTitle("transaction-detail-close-to".localized)
        closeToView.isUserInteractionEnabled = true

        verticalStackView.addArrangedSubview(closeToView)
    }
    
    private func addFeeView(_ theme: TransactionDetailViewTheme) {
        feeView.customize(theme.commonTransactionAmountInformationViewTheme)
        feeView.setTitle("transaction-detail-fee".localized)

        verticalStackView.addArrangedSubview(feeView)
    }
    
    private func addDateView(_ theme: TransactionDetailViewTheme) {
        dateView.customize(theme.transactionTextInformationViewCommonTheme)
        dateView.setTitle("transaction-detail-date".localized)

        verticalStackView.addArrangedSubview(dateView)
    }
    
    private func addRoundView(_ theme: TransactionDetailViewTheme) {
        roundView.customize(theme.transactionTextInformationViewCommonTheme)
        roundView.setTitle("transaction-detail-round".localized)

        verticalStackView.addArrangedSubview(roundView)
    }
    
    private func addIdView(_ theme: TransactionDetailViewTheme) {
        idView.customize(theme.transactionTextInformationViewTransactionIDTheme)
        idView.setTitle("transaction-detail-id".localized)

        verticalStackView.addArrangedSubview(idView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: idView)
        idView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }
    
    private func addNoteView(_ theme: TransactionDetailViewTheme) {
        noteView.setTitle("transaction-detail-note".localized)
        noteView.isUserInteractionEnabled = true

        verticalStackView.addArrangedSubview(noteView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: noteView)
        noteView.addSeparator(theme.separator, padding: theme.separatorTopPadding)
    }

    private func addOpenInAlgoExplorerButton(_ theme: TransactionDetailViewTheme) {
        openInAlgoExplorerButton.customizeAppearance(theme.openInAlgoExplorerButton)
        openInAlgoExplorerButton.layer.draw(corner: theme.buttonsCorner)

        addSubview(openInAlgoExplorerButton)
        openInAlgoExplorerButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)

        openInAlgoExplorerButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(verticalStackView.snp.bottom).offset(theme.bottomPaddingForSeparator)
        }
    }

    private func addOpenInGoalSeekerButton(_ theme: TransactionDetailViewTheme) {
        openInGoalSeekerButton.customizeAppearance(theme.openInGoalSeekerButton)
        openInGoalSeekerButton.layer.draw(corner: theme.buttonsCorner)

        addSubview(openInGoalSeekerButton)
        openInGoalSeekerButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)

        openInGoalSeekerButton.snp.makeConstraints {
            $0.leading.equalTo(openInAlgoExplorerButton.snp.trailing).offset(theme.openInGoalSeekerButtonLeadingPadding)
            $0.centerY.equalTo(openInAlgoExplorerButton)
        }
    }
}

extension TransactionDetailView: TransactionContactInformationViewDelegate {
    func transactionContactInformationViewDidTapAddContactButton(_ transactionContactInformationView: TransactionContactInformationView) {
        delegate?.transactionDetailViewDidTapAddContactButton(self)
    }
}

extension TransactionDetailView {
    @objc
    private func notifyDelegateToCopyCloseToView() {
        delegate?.transactionDetailViewDidCopyCloseToAddress(self)
    }
    
    @objc
    private func notifyDelegateToCopyOpponentView() {
        delegate?.transactionDetailViewDidCopyOpponentAddress(self)
    }
    
    @objc
    private func notifyDelegateToCopyNoteView() {
        delegate?.transactionDetailViewDidCopyTransactionNote(self)
    }

    @objc
    private func notifyDelegateToCopyTransactionID() {
        delegate?.transactionDetailViewDidCopyTransactionID(self)
    }

    @objc
    func notifyDelegateToOpenAlgoExplorer() {
        delegate?.transactionDetailView(self, didOpen: .algoexplorer)
    }

    @objc
    func notifyDelegateToOpenGoalSeaker() {
        delegate?.transactionDetailView(self, didOpen: .goalseeker)
    }
}

extension TransactionDetailView: ViewModelBindable {
    func bindData(_ viewModel: TransactionDetailViewModel?) {
        closeToView.setDetail(viewModel?.closeToViewDetail)
        closeToView.isHidden = (viewModel?.closeToViewIsHidden).falseIfNil
        if let rewardViewMode = viewModel?.rewardViewMode {
            rewardView.bindAmountViewMode(rewardViewMode)
        }
        rewardView.isHidden = (viewModel?.rewardViewIsHidden).falseIfNil
        if let closeAmountViewMode = viewModel?.closeAmountViewMode {
            closeAmountView.bindAmountViewMode(closeAmountViewMode)
        }
        closeAmountView.isHidden = (viewModel?.closeAmountViewIsHidden).falseIfNil
        noteView.setDetail(viewModel?.noteViewDetail)
        noteView.isHidden = (viewModel?.noteViewIsHidden).falseIfNil
        roundView.setDetail(viewModel?.roundViewDetail)
        roundView.isHidden = (viewModel?.roundViewIsHidden).falseIfNil
        dateView.setDetail(viewModel?.date)
        idView.setDetail(viewModel?.transactionID)
        if let status = viewModel?.transactionStatus {
            statusView.setTransactionStatus(status)
        }
        userView.setTitle(viewModel?.userViewTitle)
        userView.setDetail(viewModel?.userViewDetail)
        if let feeViewMode = viewModel?.feeViewMode {
            feeView.bindAmountViewMode(feeViewMode)
        }
        opponentView.setTitle(viewModel?.opponentViewTitle)
        if let transactionAmountViewMode = viewModel?.transactionAmountViewMode {
            amountView.bindAmountViewMode(transactionAmountViewMode)
        }

        bindOpponentViewDetail(viewModel)
    }

    func bindOpponentViewDetail(_ viewModel: TransactionDetailViewModel?) {
        if let contact = viewModel?.opponentViewContact {
            opponentView.setContact(contact)
        } else if let opponentViewAddress = viewModel?.opponentViewAddress {
            opponentView.setName(opponentViewAddress)
        }
    }
}

protocol TransactionDetailViewDelegate: AnyObject {
    func transactionDetailViewDidTapAddContactButton(_ transactionDetailView: TransactionDetailView)
    func transactionDetailViewDidCopyTransactionID(_ transactionDetailView: TransactionDetailView)
    func transactionDetailViewDidCopyOpponentAddress(_ transactionDetailView: TransactionDetailView)
    func transactionDetailViewDidCopyCloseToAddress(_ transactionDetailView: TransactionDetailView)
    func transactionDetailView(_ transactionDetailView: TransactionDetailView, didOpen explorer: AlgoExplorerType)
    func transactionDetailViewDidCopyTransactionNote(_ transactionDetailView: TransactionDetailView)
}
