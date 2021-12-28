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
//   SendTransactionPreviewScreen.swift


import Foundation
import UIKit
import MacaroonUIKit


final class SendTransactionPreviewScreen: BaseViewController {
    private lazy var transactionDetailView = NewSendTransactionPreviewView(draft: draft)

    private let draft: SendTransactionDraft

    private let viewModel = SendTransactionPreviewViewModel()

    init(
        draft: SendTransactionDraft,
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: AppColors.Shared.System.background)
        title = "transaction-detail-title".localized
    }

    override func prepareLayout() {
        super.prepareLayout()
        addTransactionDetailView()
    }

    override func bindData() {
        super.bindData()

        viewModel.configureReceivedTransaction(transactionDetailView, with: draft)
    }
}


extension SendTransactionPreviewScreen {
    private func addTransactionDetailView() {
        view.addSubview(transactionDetailView)
        transactionDetailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
