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

//   VerificationInfoViewController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class VerificationInfoViewController: ScrollScreen {
    private lazy var theme = Theme()

    private lazy var headerView = VerificationInfoHeaderView()
    private lazy var contextView = VerificationInfoView()
    private lazy var learnButton = MacaroonUIKit.Button()

    let configuration: ViewControllerConfiguration

    init(
        configuration: ViewControllerConfiguration
    ) {
        self.configuration = configuration

        super.init()
    }

    override func prepareLayout() {
        super.prepareLayout()

        blursFooterBackgroundOnUnderScrolling = true

        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset.top = theme.scrollViewTopInset

        addHeader()
        addContext()
        addLearnButton()
    }

    override func setListeners() {
        super.setListeners()

        headerView.observe(event: .closeScreen) {
            [weak self] in
            guard let self = self else { return }
            self.dismissScreen()
        }

        learnButton.addTarget(self, action: #selector(didTapLearnButton), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(
            true,
            animated: true
        )
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        updateHeaderOnScroll(scrollView)
    }
}

extension VerificationInfoViewController {
    @objc
    private func didTapLearnButton() {
        open(AlgorandWeb.asaVerification.link)
    }
}

extension VerificationInfoViewController {
    private func addHeader() {
        headerView.customize(theme.header)
        headerView.bindData(VerificationInfoHeaderViewModel())

        view.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.fitToHeight(theme.headerMaxHeight)
        }
    }

    private func addContext() {
        contextView.customize(theme.context)
        contextView.bindData(VerificationInfoViewModel())

        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addLearnButton() {
        learnButton.contentEdgeInsets = UIEdgeInsets(theme.buttonContentInsets)
        learnButton.draw(corner: theme.buttonCorner)
        learnButton.customizeAppearance(theme.button)

        footerView.addSubview(learnButton)
        learnButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.buttonHorizontalPadding)
            $0.top.equalToSuperview().inset(theme.buttonTopPadding)
            $0.bottom.equalToSuperview().inset(theme.buttonBottomPadding)
        }
    }

    private func updateHeaderOnScroll(_ scrollView: UIScrollView) {
        let contentY = scrollView.contentOffset.y + scrollView.contentInset.top

        let height = theme.headerMaxHeight - contentY

        if height < theme.headerMinHeight {
            return
        }

        headerView.snp.updateConstraints {
            $0.fitToHeight(height)
        }
    }
}
