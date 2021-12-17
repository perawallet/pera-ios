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
//   SendTransactionScreen.swift


import Foundation
import UIKit
import SnapKit
import MagpieHipo
import Alamofire
import MacaroonUIKit


final class SendTransactionScreen: BaseViewController {
    private(set) lazy var modalTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var nextButton = Button()
    private lazy var accountContainerView = TripleShadowableView()
    private lazy var accountView = AssetPreviewView()
    private lazy var numpadView = NumpadView(mode: .decimal)
    private lazy var noteButton = Button()
    private lazy var maxButton = Button()
    private lazy var usdValueLabel = UILabel()
    private lazy var valueLabel = UILabel()

    private let theme = Theme()
    private var draft: SendTransactionDraft

    private var amount: String = "0"
    private var note: String? {
        didSet {
            let isSelected = note != nil && note != ""

            if isSelected {
                noteButton.setTitle("send-transaction-edit-note-title".localized, for: .normal)
            } else {
                noteButton.setTitle("send-transaction-add-note-title".localized, for: .normal)
            }
        }
    }

    private var isMaxTransaction: Bool {
        guard let decimalAmount = amount.decimalAmountWithSeparator else {
            return false
        }
        return draft.account.amount == decimalAmount.toMicroAlgos
    }

    init(draft: SendTransactionDraft, configuration: ViewControllerConfiguration) {
        self.draft = draft
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = theme.backgroundColor

        switch draft.transactionMode {
        case .assetDetail(let assetDetail):
            title = "send-transaction-title".localized(assetDetail.getDisplayNames().0)
        case .algo:
            title = "send-transaction-title".localized("asset-algos-title".localized)
        }
    }

    override func prepareLayout() {
        super.prepareLayout()

        addNextButton()
        addAccountView()
        addNumpad()
        addButtons()
        addLabels()
    }

    override func bindData() {
        super.bindData()

        bindAssetPreview()
        bindAmount()
    }

    override func linkInteractors() {
        super.linkInteractors()

        numpadView.linkInteractors()
        numpadView.delegate = self

        maxButton.addTarget(self, action: #selector(didTapMax), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        noteButton.addTarget(self, action: #selector(didTapNote), for: .touchUpInside)
    }
}

extension SendTransactionScreen {
    private func bindAssetPreview() {
        switch draft.transactionMode {
        case .algo:
            accountView.bindData(
                AssetPreviewViewModel(AssetPreviewModelAdapter.adapt(draft.account))
            )
        case .assetDetail(let assetDetail):
            if let asset = draft.account.assets?.first(matching: (\.id, assetDetail.id)) {
                accountView.bindData(
                    AssetPreviewViewModel(AssetPreviewModelAdapter.adaptAssetSelection((assetDetail, asset)))
                )
            }
        }
    }

    private func bindAmount() {
        let amountValue = self.amount
        var showingValue = ""

        valueLabel.customizeAppearance(theme.valueLabelStyle)

        if let decimalStrings = amountValue.decimalStrings() {
            switch draft.transactionMode {
            case .algo:
                showingValue = (amountValue.replacingOccurrences(of: decimalStrings, with: "")
                    .decimalAmountWithSeparator?.toNumberStringWithSeparatorForLabel ?? amountValue)
                    .appending(decimalStrings)
            case .assetDetail(let assetDetail):
                showingValue = (amountValue.replacingOccurrences(of: decimalStrings, with: "")
                    .decimalAmountWithSeparator?.toNumberStringWithSeparatorForLabel(fraction: assetDetail.fractionDecimals) ?? amountValue)
                    .appending(decimalStrings)
            }
        } else {
            showingValue = amountValue.decimalAmountWithSeparator?.toNumberStringWithSeparatorForLabel ?? amountValue

            if self.amount.decimal.number.intValue == 0 {
                if let string = self.amount.decimal.toFractionStringForLabel(fraction: 2) {
                    showingValue = string
                }
                valueLabel.customizeAppearance(theme.disabledValueLabelStyle)
            }
        }

        valueLabel.text = showingValue
    }
}

extension SendTransactionScreen {
    private func addNextButton() {
        nextButton.customize(theme.nextButtonStyle)
        nextButton.setTitle("title-next".localized, for: .normal)

        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(theme.defaultBottomInset)
            make.leading.trailing.equalToSuperview().inset(theme.defaultLeadingInset)
            make.height.equalTo(theme.nextButtonHeight)
        }
    }

    private func addAccountView() {
        accountView.customize(AssetPreviewViewCommonTheme())

        accountContainerView.draw(corner: theme.accountContainerCorner)
        accountContainerView.drawAppearance(border: theme.accountContainerBorder)

        accountContainerView.drawAppearance(shadow: theme.accountContainerFirstShadow)
        accountContainerView.drawAppearance(secondShadow: theme.accountContainerSecondShadow)
        accountContainerView.drawAppearance(thirdShadow: theme.accountContainerThirdShadow)

        view.addSubview(accountContainerView)
        accountContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).offset(theme.defaultBottomInset)
            make.leading.trailing.equalToSuperview().inset(theme.defaultLeadingInset)
            make.height.equalTo(theme.accountContainerHeight)
        }

        accountContainerView.addSubview(accountView)
        accountView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(theme.accountLeadingInset)
            make.top.bottom.equalToSuperview()
        }
    }

    private func addNumpad() {
        numpadView.customize(TransactionNumpadViewTheme())

        view.addSubview(numpadView)
        numpadView.snp.makeConstraints { make in
            make.bottom.equalTo(accountView.snp.top).offset(theme.numpadBottomInset)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func addButtons() {
        let stackView = HStackView()
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = theme.buttonsSpacing

        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.bottom.equalTo(numpadView.snp.top).offset(theme.buttonsBottomInset)
            make.leading.trailing.equalToSuperview().inset(theme.buttonsLeadingInset)
            make.height.equalTo(theme.buttonsHeight)
        }

        noteButton.setTitle("send-transaction-add-note-title".localized, for: .normal)
        maxButton.setTitle("send-transaction-max-button-title".localized, for: .normal)

        maxButton.customize(TransactionShadowButtonTheme())
        noteButton.customize(TransactionShadowButtonTheme())

        maxButton.drawAppearance(border: theme.accountContainerBorder)
        noteButton.drawAppearance(border: theme.accountContainerBorder)
        stackView.addArrangedSubview(noteButton)
        stackView.addArrangedSubview(maxButton)
    }

    private func addLabels() {
        let labelStackView = VStackView()
        labelStackView.alignment = .center
        labelStackView.distribution = .equalCentering

        usdValueLabel.customizeAppearance(theme.usdValueLabelStyle)
        valueLabel.customizeAppearance(theme.disabledValueLabelStyle)

        view.addSubview(labelStackView)
        labelStackView.snp.makeConstraints { make in
            make.height.equalTo(theme.labelsContainerHeight)
            make.bottom.equalTo(maxButton.snp.top).offset(theme.labelsContainerBottomInset)
            make.leading.trailing.equalToSuperview().inset(theme.defaultLeadingInset)
        }

        labelStackView.addArrangedSubview(valueLabel)
        labelStackView.addArrangedSubview(usdValueLabel)
    }
}

extension SendTransactionScreen {
    @objc
    private func didTapNext() {
        let validation = validate(value: amount)

        switch validation {
        case .otherAlgo:
            self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-minimum-amount-error".localized)
        case .minimumAmountAlgoError:
            self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-minimum-amount-error".localized)
        case .maximumAmountAlgoError:
            self.displaySimpleAlertWith(title: "title-error".localized, message: "send-algos-amount-error".localized)
        case .minimumAmountAssetError:
            self.displaySimpleAlertWith(title: "title-error".localized, message: "send-asset-amount-error".localized)
        case .otherAsset:
            self.displaySimpleAlertWith(title: "title-error".localized, message: "send-asset-amount-error".localized)
        case .valid:
            return
        case .algoParticipationKeyWarning:
            self.presentParticipationKeyWarningForMaxTransaction()
        case .maxAlgo:
            self.displayMaxTransactionWarning()
        }
    }

    @objc
    private func didTapMax() {
        switch draft.transactionMode {
        case .algo:
            self.amount = draft.account.amount.toAlgos.toNumberStringWithSeparatorForLabel ?? "0"
        case .assetDetail(let assetDetail):
            self.amount = draft.account.amountNumberWithAutoFraction(for: assetDetail) ?? "0"
        }

        bindAmount()
    }

    @objc
    private func didTapNote() {
        modalTransition.perform(.editNote(note: self.note, delegate: self), completion: nil)
    }
}

extension SendTransactionScreen: NumpadViewDelegate {
    func numpadView(_ numpadView: NumpadView, didSelect value: NumpadKey) {
        var newValue = self.amount

        if newValue.fractionCount() >= draft.fractionCount && value != .delete {
            return
        }

        switch value {
        case .number(let numberValue):
            if self.amount == "0" {
                newValue = numberValue
            } else {
                newValue.append(contentsOf: numberValue)
            }
        case .spacing:
            return
        case .delete:
            if self.amount.count == 1 {
                newValue = "0"
            } else if self.amount == "0" {
                return
            } else {
                newValue.removeLast(1)
            }

        case .decimalSeparator:
            let decimalSeparator = Locale.preferred().decimalSeparator?.first ?? "."

            if self.amount.contains(decimalSeparator) {
                return
            }
            newValue.append(decimalSeparator)
        }

        self.amount = newValue
        bindAmount()

    }

    private func validate(value: String) -> TransactionValidation {
        switch draft.transactionMode {
        case .algo:
            return validateAlgo(for: value)
        case .assetDetail(let assetDetail):
            return validateAsset(for: value, on: assetDetail)
        }

    }

    private func validateAlgo(for value: String) -> TransactionValidation {
        guard let decimalAmount = value.decimalAmountWithSeparator else {
            return .otherAlgo
        }

        if draft.account.amount < UInt64(decimalAmount.toMicroAlgos) {
            return .maximumAmountAlgoError
        }

        if Int(draft.account.amount) - Int(decimalAmount.toMicroAlgos) - Int(minimumFee) < minimumTransactionMicroAlgosLimit && !isMaxTransaction {
            return .minimumAmountAlgoError
        }

        if isMaxTransaction {
            if draft.account.doesAccountHasParticipationKey() {
                return .algoParticipationKeyWarning
            } else if draft.account.hasMinAmountFields || draft.account.isRekeyed() {
                displayMaxTransactionWarning()
                return .maxAlgo
            }
        }

        return .valid
    }

    private func validateAsset(for value: String, on assetDetail: AssetDetail) -> TransactionValidation {
        guard let assetAmount = draft.account.amount(for: assetDetail),
              let decimalAmount = value.decimalAmountWithSeparator else {
                  return .otherAsset
        }

        if assetAmount < decimalAmount {
            return .minimumAmountAssetError
        }

        return .valid
    }

    private func presentParticipationKeyWarningForMaxTransaction() {
        let alertController = UIAlertController(
            title: "send-algos-account-delete-title".localized,
            message: "send-algos-account-delete-body".localized,
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel)

        let proceedAction = UIAlertAction(title: "title-proceed".localized, style: .destructive) { _ in
            self.displayMaxTransactionWarning()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(proceedAction)

        present(alertController, animated: true, completion: nil)
    }

    private func displayMaxTransactionWarning() {
        modalTransition.perform(.maximumBalanceWarning(account: draft.account, delegate: self))
    }
}

extension SendTransactionScreen: EditNoteScreenDelegate {
    func editNoteScreen(
        _ editNoteScreen: EditNoteScreen,
        didUpdateNote note: String?
    ) {
        self.note = note
    }
}

extension SendTransactionScreen: MaximumBalanceWarningViewControllerDelegate {
    func maximumBalanceWarningViewControllerDidConfirmWarning(_ maximumBalanceWarningViewController: MaximumBalanceWarningViewController) {
        maximumBalanceWarningViewController.dismissScreen()
        //next screen
    }
}

extension SendTransactionScreen {
    enum TransactionValidation {
        case otherAlgo
        case otherAsset
        case minimumAmountAlgoError
        case maximumAmountAlgoError
        case minimumAmountAssetError
        case valid
        case algoParticipationKeyWarning
        case maxAlgo
    }
}
