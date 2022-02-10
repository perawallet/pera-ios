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
//   WCGroupTransactionItemView.swift

import UIKit
import MacaroonUIKit

class WCGroupTransactionItemView: TripleShadowView {

    private let layout = Layout<LayoutConstants>()

    private lazy var senderStackView: HStackView = {
        let stackView = HStackView()
        stackView.distribution = .equalSpacing
        stackView.spacing = 8.0
        stackView.alignment = .leading
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return stackView
    }()

    private lazy var warningImageView = UIImageView(image: img("icon-red-warning"))

    private lazy var senderLabel: UILabel = {
        UILabel()
            .withTextColor(AppColors.Components.Text.grayLighter.uiColor)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(Fonts.DMSans.regular.make(13).uiFont)
    }()

    private lazy var balanceStackView: HStackView = {
        let stackView = HStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 4.0
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return stackView
    }()

    private lazy var balanceLabel: UILabel = {
        UILabel()
            .withTextColor(AppColors.Components.Text.main.uiColor)
            .withLine(.contained)
            .withAlignment(.left)
            .withFont(Fonts.DMMono.regular.make(19).uiFont)
    }()

    private lazy var dollarValueLabel: UILabel = {
        UILabel()
            .withTextColor(AppColors.Components.Text.gray.uiColor)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(Fonts.DMSans.regular.make(13).uiFont)
    }()

    private lazy var showDetailLabel: UILabel = {
        UILabel()
            .withTextColor(AppColors.Components.Link.primary.uiColor)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(Fonts.DMSans.bold.make(13).uiFont)
            .withText("title-show-transaction-detail".localized)
    }()

    private(set) lazy var accountInformationView = WCGroupTransactionAccountInformationView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureAppearance()
        prepareLayout()
    }

    func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        layer.cornerRadius = 12.0

        let accountContainerCorner = Corner(radius: 4)
        let accountContainerBorder = Border(color: AppColors.SendTransaction.Shadow.first.uiColor, width: 1)

        let accountContainerFirstShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.first.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        let accountContainerSecondShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.second.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        let accountContainerThirdShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.third.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        draw(corner: accountContainerCorner)
        drawAppearance(border: accountContainerBorder)

        drawAppearance(shadow: accountContainerFirstShadow)
        drawAppearance(secondShadow: accountContainerSecondShadow)
        drawAppearance(thirdShadow: accountContainerThirdShadow)
    }

    func prepareLayout() {
        setupAccountInformationViewLayout()
        setupBalanceStackViewLayout()
        setupDollarValueViewLayout()
        setupShowDetailLabelLayout()
    }

    func removeAccountInformation() {
        accountInformationView.removeFromSuperview()

        balanceStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.accountInformationViewInset)
        }
    }
}

extension WCGroupTransactionItemView {
    private func setupAccountInformationViewLayout() {
        addSubview(accountInformationView)

        accountInformationView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.accountInformationViewInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.accountInformationViewInset)
            make.height.greaterThanOrEqualTo(layout.current.accountInformationHeight)
        }
    }

    private func setupBalanceStackViewLayout() {
        addSubview(balanceStackView)

        balanceStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(accountInformationView.snp.bottom).offset(layout.current.balanceStackTopInset)
        }

        balanceStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        balanceStackView.addArrangedSubview(warningImageView)
        balanceStackView.addArrangedSubview(balanceLabel)

        balanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        balanceLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        let spacer = UIView()
        let spacerWidthConstraint = spacer.widthAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
        spacerWidthConstraint.priority = .defaultLow
        spacerWidthConstraint.isActive = true
        balanceStackView.addArrangedSubview(spacer)

        warningImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.fitToSize((24, 24))
        }
    }

    private func setupDollarValueViewLayout() {
        addSubview(dollarValueLabel)
        dollarValueLabel.snp.makeConstraints { make in
            make.top.equalTo(balanceStackView.snp.bottom).offset(layout.current.dollarValueTopInset)
            make.leading.equalTo(balanceStackView)
            make.trailing.equalToSuperview()
        }
    }

    private func setupShowDetailLabelLayout() {
        addSubview(showDetailLabel)

        showDetailLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
}

extension WCGroupTransactionItemView {
    func bind(_ viewModel: WCGroupTransactionItemViewModel) {
        warningImageView.isHidden = !viewModel.hasWarning
        dollarValueLabel.text = viewModel.usdValue

        if viewModel.title != nil {
            balanceLabel.text = viewModel.title
        } else {
            if let amount = viewModel.amount {
                if let assetName = viewModel.assetName {
                    balanceLabel.text = "\(amount) \(assetName)"
                } else {
                    balanceLabel.text = amount
                }
            } else {
                balanceLabel.text = viewModel.assetName
            }
        }

        if let accountInformationViewModel = viewModel.accountInformationViewModel {
            accountInformationView.bind(accountInformationViewModel)
        }
    }
}

extension WCGroupTransactionItemView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let senderStackHeight: CGFloat = 20.0
        let arrowImageSize = CGSize(width: 24.0, height: 24.0)
        let arrowImageTopInset: CGFloat = 36.0
        let balanceStackHeight: CGFloat = 24.0
        let balanceStackTopInset: CGFloat = 8.0
        let accountInformationHeight: CGFloat = 36.0
        let accountInformationViewTopInset: CGFloat = 12.0
        let accountInformationViewInset: CGFloat = 8.0
        let dollarValueTopInset: CGFloat = 4.0
    }
}
