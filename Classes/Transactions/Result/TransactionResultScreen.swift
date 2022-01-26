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
//   TransactionResultScreen.swift


import Foundation
import UIKit
import MacaroonUIKit

final class TransactionResultScreen: BaseViewController {
    private lazy var theme = Theme()
    private lazy var titleLabel = UILabel()
    private lazy var subtitleLabel = UILabel()

    private var status: TransactionResultScreen.Status = .started

    override var shouldShowNavigationBar: Bool {
        return false
    }

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        titleLabel.customizeAppearance(theme.titleLabel)
        subtitleLabel.customizeAppearance(theme.subtitleLabel)

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func prepareLayout() {
        super.prepareLayout()

        addTitleLabel()
        addSubtitleLabel()
    }

    override func bindData() {
        super.bindData()

        titleLabel.text = status.title
        subtitleLabel.text = status.subtitle
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Close screen after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else {
                return
            }

            self.dismissScreen()
        }
    }
}

extension TransactionResultScreen {
    private func addTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.titleLeadingInset)
            $0.centerY.equalToSuperview()
        }
    }

    private func addSubtitleLabel() {
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.subtitleLeadingInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.subtitleTopOffset)
        }
    }
}

extension TransactionResultScreen {
    enum Status {
        case started
        case inProgress
        case completed
    }
}

extension TransactionResultScreen.Status {
    var title: String {
        switch self {
        case .started, .inProgress:
            return "transaction-result-started-title".localized
        case .completed:
            return "transaction-result-completed-title".localized
        }
    }

    var subtitle: String {
        switch self {
        case .started, .inProgress:
            return "transaction-result-started-subtitle".localized
        case .completed:
            return "transaction-result-completed-subtitle".localized
        }
    }
}
