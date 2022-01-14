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
//   PortfolioCalculationDescriptionView.swift

import UIKit
import MacaroonUIKit

final class PortfolioCalculationDescriptionView: View {
    lazy var handlers = Handlers()

    private lazy var stackView = VStackView()
    private lazy var errorView = AccountPortfolioErrorView()
    private lazy var titleLabel = UILabel()
    private lazy var detailLabel = UILabel()
    private lazy var closeButton = ViewFactory.Button.makeSecondaryButton("title-close".localized)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
        customize(PortfolioCalculationDescriptionViewTheme())
    }

    func setListeners() {
        closeButton.addTarget(self, action: #selector(didCloseScreen), for: .touchUpInside)
    }

    private func customize(_ theme: PortfolioCalculationDescriptionViewTheme) {
        addStackView(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) { }
    func prepareLayout(_ layoutSheet: LayoutSheet) { }
}

extension PortfolioCalculationDescriptionView {
    private func addStackView(_ theme: PortfolioCalculationDescriptionViewTheme) {
        stackView.distribution = .equalSpacing
        stackView.spacing = theme.stackViewSpacing

        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(theme.topPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.bottomPadding)
        }

        stackView.addArrangedSubview(errorView)
        stackView.addArrangedSubview(titleLabel)
        titleLabel.customizeAppearance(theme.title)

        stackView.setCustomSpacing(theme.detailPadding, after: titleLabel)
        stackView.addArrangedSubview(detailLabel)
        detailLabel.customizeAppearance(theme.detail)

        stackView.setCustomSpacing(theme.bottomPadding, after: detailLabel)
        stackView.addArrangedSubview(closeButton)
    }
}

extension PortfolioCalculationDescriptionView {
    @objc
    private func didCloseScreen() {
        handlers.didCloseScreen?()
    }
}

extension PortfolioCalculationDescriptionView {
    func bindData(_ viewModel: PortfolioCalculationDescriptionViewModel) {
        errorView.isHidden = !viewModel.hasError
    }
}

extension PortfolioCalculationDescriptionView {
    struct Handlers {
        var didCloseScreen: EmptyHandler?
    }
}
