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
   private lazy var transactionDetailView = NewSendTransactionPreviewView()
   private lazy var nextButton = Button()
   private lazy var theme = Theme()

   private let draft: TransactionSendDraft?
   private let transactionController: TransactionController

   private let viewModel = SendTransactionPreviewViewModel()

   init(
      draft: TransactionSendDraft?,
      transactionController: TransactionController,
      configuration: ViewControllerConfiguration
   ) {
      self.draft = draft
      self.transactionController = transactionController
      super.init(configuration: configuration)
   }

   override func configureAppearance() {
      super.configureAppearance()
      view.customizeBaseAppearance(backgroundColor: AppColors.Shared.System.background)
      title = "send-transaction-preview-title".localized
   }

   override func prepareLayout() {
      super.prepareLayout()
      addNextButton()
      addTransactionDetailView()
   }

   override func bindData() {
      super.bindData()

      if let algoTransactionDraft = draft as? AlgosTransactionSendDraft {
         viewModel.configureReceivedTransaction(transactionDetailView, with: algoTransactionDraft)
      } else if let assetTransactionDraft = draft as? AssetTransactionSendDraft {
         viewModel.configureReceivedTransaction(transactionDetailView, with: assetTransactionDraft)
      }
   }

   override func linkInteractors() {
      super.linkInteractors()

      nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
   }
}

extension SendTransactionPreviewScreen {
   @objc
   private func didTapNext() {
      loadingController?.startLoadingWithMessage("title-loading".localized)
      transactionController.uploadTransaction { [weak self] in
         guard let self = self else {
            return
         }

         self.loadingController?.stopLoading()

         self.open(.transactionResult, by: .push)
      }
   }
}

extension SendTransactionPreviewScreen {
   private func addTransactionDetailView() {
      view.addSubview(transactionDetailView)
      transactionDetailView.snp.makeConstraints {
         $0.top.leading.trailing.equalToSuperview()
         $0.bottom.equalTo(nextButton.snp.top).offset(theme.nextButtonTopPadding)
      }
   }

   private func addNextButton() {
      nextButton.customize(theme.nextButtonStyle)
      nextButton.setTitle("title-send".localized, for: .normal)
      view.addSubview(nextButton)
      
      nextButton.snp.makeConstraints {
         $0.leading.trailing.equalToSuperview().inset(theme.nextButtonLeadingInset)
         $0.bottom.safeEqualToBottom(of: self).inset(theme.nextButtonBottomInset)
         $0.height.equalTo(theme.nextButtonHeight)
      }
   }
}
