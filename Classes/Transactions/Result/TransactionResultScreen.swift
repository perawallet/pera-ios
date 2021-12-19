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

    var status: TransactionResultScreen.Status = .started

    override var shouldShowNavigationBar: Bool {
        return false
    }

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        titleLabel.customizeAppearance(theme.titleLabel)
        subtitleLabel.customizeAppearance(theme.subtitleLabel)
    }

    override func prepareLayout() {

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
        }
    }

    override func bindData() {
        super.bindData()

        titleLabel.text = status.title()
        subtitleLabel.text = status.subtitle()
    }
}

extension TransactionResultScreen {
    enum Status {
        case started
        case inProgress(progress: CGFloat)
        case completed
    }
}

extension TransactionResultScreen.Status {
    func title() -> String {
        switch self {
        case .started, .inProgress:
            return "transaction-result-started-title".localized
        case .completed:
            return "transaction-result-completed-title".localized
        }
    }

    func subtitle() -> String {
        switch self {
        case .started, .inProgress:
            return "transaction-result-started-subtitle".localized
        case .completed:
            return "transaction-result-completed-subtitle".localized
        }
    }
}
