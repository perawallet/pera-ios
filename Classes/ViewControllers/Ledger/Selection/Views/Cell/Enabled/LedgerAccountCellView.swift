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
//  LedgerAccountCellView.swift

import MacaroonUIKit
import UIKit

final class LedgerAccountCellView:
    View,
    TripleShadowDrawable,
    ViewModelBindable,
    ListReusable {
    var thirdShadow: MacaroonUIKit.Shadow?
    var thirdShadowLayer: CAShapeLayer = CAShapeLayer()

    var secondShadow: MacaroonUIKit.Shadow?
    var secondShadowLayer: CAShapeLayer = CAShapeLayer()

    weak var delegate: LedgerAccountViewDelegate?

    private var theme: LedgerAccountCellViewTheme?

    private lazy var checkboxImageView = UIImageView()
    private lazy var accountItemView = AccountListItemView()
    private lazy var infoButton = UIButton()

    override func preferredUserInterfaceStyleDidChange() {
        super.preferredUserInterfaceStyleDidChange()

        drawAppearance(
            secondShadow: secondShadow
        )
        drawAppearance(
            thirdShadow: thirdShadow
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let secondShadow = secondShadow {
            updateOnLayoutSubviews(
                secondShadow: secondShadow
            )
        }

        if let thirdShadow = thirdShadow {
            updateOnLayoutSubviews(
                thirdShadow: thirdShadow
            )
        }
    }

    func customize(_ theme: LedgerAccountCellViewTheme) {
        self.theme = theme

        drawAppearance(corner: theme.corner)
        drawAppearance(shadow: theme.firstShadow)
        drawAppearance(secondShadow: theme.secondShadow)
        drawAppearance(thirdShadow: theme.thirdShadow)

        addCheckboxImage(theme)
        addInfo(theme)
        addAccountItem(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    static func calculatePreferredSize(
        _ viewModel: LedgerAccountViewModel?,
        for theme: LedgerAccountCellViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let accountItemWidth =
            width -
            theme.horizontalInset -
            theme.checkboxIconSize.w -
            theme.horizontalInset -
            theme.infoIconSize.w -
            theme.horizontalInset
        let maxAccountItemSize = CGSize(width: accountItemWidth, height: .greatestFiniteMagnitude)
        let accountItemSize = AccountListItemView.calculatePreferredSize(
            viewModel?.accountItem,
            for: theme.accountItem,
            fittingIn: maxAccountItemSize
        )
        let preferredHeight =
            theme.verticalInset +
            accountItemSize.height +
            theme.verticalInset
        return CGSize((width, min(preferredHeight, size.height)))
    }

    func bindData(_ viewModel: LedgerAccountViewModel?) {
        accountItemView.bindData(viewModel?.accountItem)
    }
}

extension LedgerAccountCellView {
    private func addCheckboxImage(_ theme: LedgerAccountCellViewTheme) {
        checkboxImageView.customizeAppearance(theme.unselectedStateCheckbox)

        addSubview(checkboxImageView)
        checkboxImageView.fitToIntrinsicSize()
        checkboxImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.fitToSize(theme.checkboxIconSize)
        }
    }

    private func addInfo(_ theme: LedgerAccountCellViewTheme) {
        infoButton.customizeAppearance(theme.infoButtonStyle)

        addSubview(infoButton)
        infoButton.fitToIntrinsicSize()
        infoButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.fitToSize(theme.infoIconSize)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }

        infoButton.addTouch(
            target: self,
            action: #selector(notifyDelegateToOpenMoreInfo)
        )
    }

    private func addAccountItem(_ theme: LedgerAccountCellViewTheme) {
        accountItemView.customize(theme.accountItem)

        addSubview(accountItemView)
        accountItemView.snp.makeConstraints {
            $0.leading.equalTo(checkboxImageView.snp.trailing).offset(theme.horizontalInset)
            $0.trailing.equalTo(infoButton.snp.leading).offset(-theme.horizontalInset)
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
        }
    }
}

extension LedgerAccountCellView {
    @objc
    private func notifyDelegateToOpenMoreInfo() {
        delegate?.ledgerAccountViewDidOpenMoreInfo(self)
    }
}

extension LedgerAccountCellView {
    func didSelectCell(_ selected: Bool) {
        guard let theme else { return }

        if selected {
            draw(border: theme.selectedStateBorder)
            checkboxImageView.customizeAppearance(theme.selectedStateCheckbox)
        } else {
            eraseBorder()
            checkboxImageView.customizeAppearance(theme.unselectedStateCheckbox)
        }
    }
}

protocol LedgerAccountViewDelegate: AnyObject {
    func ledgerAccountViewDidOpenMoreInfo(_ ledgerAccountView: LedgerAccountCellView)
}
