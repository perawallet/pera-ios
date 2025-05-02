// Copyright 2024 Pera Wallet, LDA

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
//   SendAssetAndOptInTransactionInfoScreen.swift

import Foundation
import UIKit
import MacaroonUIKit

final class SendAssetAndOptInTransactionInfoScreen: BaseScrollViewController {
   typealias EventHandler = (Event) -> Void

   override var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
      return .automatic
   }
   override var contentSizeBehaviour: BaseScrollViewController.ContentSizeBehaviour {
      return .intrinsic
   }
    
   override var shouldShowNavigationBar: Bool {
      return false
   }

   var eventHandler: EventHandler?

   private lazy var continueButton = Button()
   private lazy var dontShowAgainButton = Button()
   private lazy var headerView = UIView()
   private lazy var titleLabel = UILabel()
   private lazy var theme = Theme()
    
   let viewModel = SendAssetAndOptInTransactionInfoScreenViewModel()

   private lazy var transactionController = {
      guard let api = api else {
         fatalError("API should be set.")
      }
      return TransactionController(
         api: api,
         sharedDataController: sharedDataController,
         bannerController: bannerController,
         analytics: analytics
      )
   }()

   override func configureAppearance() {
      super.configureAppearance()
      view.customizeBaseAppearance(backgroundColor: theme.background)
   }

   override func prepareLayout() {
      super.prepareLayout()
      addHeaderView()
      addBodyView()
   }

   override func linkInteractors() {
      super.linkInteractors()

      dontShowAgainButton.addTarget(self, action: #selector(didTapDontShowAgain), for: .touchUpInside)
      continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
   }

    override func addFooter() {
        view.addSubview(footerView)
        footerView.snp.makeConstraints {
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
        addButtons()
    }
}

extension SendAssetAndOptInTransactionInfoScreen {
   @objc
   private func didTapContinue() {
       self.eventHandler?(.didTapContinue)
   }
    
   @objc
   private func didTapDontShowAgain() {
       var displayStore = SendAssetAndOptInTransactionInfoScreenDisplayStore()
       displayStore.disableShowingInfoScreen()
       self.eventHandler?(.didTapContinue)
    }
}

extension SendAssetAndOptInTransactionInfoScreen {
    private func addHeaderView() {
        headerView.backgroundColor = theme.headerViewBackground.uiColor
        view.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.leading == theme.headerViewContentEdgeInsets.leading
            $0.top == theme.headerViewContentEdgeInsets.leading
            $0.trailing == theme.headerViewContentEdgeInsets.leading
            $0.height.equalTo(theme.headerViewHeight)
        }
        
        let imageView = UIImageView(image: viewModel.headerViewImage?.uiImage)
        headerView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top == theme.headerViewImageTopConstraint
        }
        
        let titleLabel = UILabel()
        viewModel.headerViewTitle?.load(in: titleLabel)
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top == imageView.snp.bottom + theme.headerViewLabelConstraint
        }
        
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.textColor = Colors.Text.sonicSilver.uiColor
        viewModel.headerViewText?.load(in: textLabel)

        headerView.addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top == titleLabel.snp.bottom + theme.headerViewLabelConstraint
            $0.leading == theme.headerViewLabelConstraint
            $0.trailing == theme.headerViewLabelConstraint
        }
    }
    
    private func addBodyView() {
        viewModel.bodyViewTitle?.load(in: titleLabel)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
         $0.top == headerView.snp.bottom + theme.bodyViewTitleContentEdgeInsets.top
         $0.leading == theme.bodyViewTitleContentEdgeInsets.leading
         $0.trailing == theme.bodyViewTitleContentEdgeInsets.trailing
         $0.height.equalTo(theme.bodyViewTitleHeight)
       }
        
        let stackView = createBulletListStackView()
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
         $0.top == titleLabel.snp.bottom + theme.bodyViewTextContentEdgeInsets.top
         $0.leading == theme.bodyViewTextContentEdgeInsets.leading
         $0.trailing == theme.bodyViewTextContentEdgeInsets.trailing
       }
    }
    
    private func createBulletListStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = theme.bodyViewBulletTextSpacing
        stackView.alignment = .firstBaseline
        
        var bulletNumber = 0
        guard let bodyViewText = viewModel.bodyViewText else { return stackView }
        for bulletText in bodyViewText {
            bulletNumber += 1
            stackView.addArrangedSubview(createBulletListRow(with: bulletNumber, and: bulletText))
        }
        
        return stackView
    }
    
    private func createBulletListRow(with bulletNumber: Int, and bulletText: TextProvider) -> UIStackView {
        let numberBulletLabel = UILabel()
        numberBulletLabel.textColor = Colors.Text.sonicSilver.uiColor
        numberBulletLabel.font = Fonts.DMSans.regular.make(13).uiFont
        numberBulletLabel.text = "\(bulletNumber)."
        numberBulletLabel.textAlignment = .right
        numberBulletLabel.translatesAutoresizingMaskIntoConstraints = false
        numberBulletLabel.widthAnchor.constraint(equalToConstant: theme.bodyViewBulletNumberTextWidth).isActive = true
        
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        bulletText.load(in: textLabel)
        textLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let horizontalStackView = UIStackView(arrangedSubviews: [numberBulletLabel, textLabel])
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .firstBaseline
        horizontalStackView.spacing = theme.bodyViewBulletStackViewSpacing
        horizontalStackView.distribution = .fill
        
        return horizontalStackView
    }
    
   private func addButtons() {
       dontShowAgainButton.customize(theme.dontShowAgainButtonStyle)
       dontShowAgainButton.bindData(ButtonCommonViewModel(title: String(localized: "title-dont-show-again")))
       continueButton.customize(theme.continueButtonStyle)
       continueButton.bindData(ButtonCommonViewModel(title: String(localized: "title-continue")))
       
       let stackView = UIStackView(arrangedSubviews: [continueButton, dontShowAgainButton])
       stackView.axis = .vertical
       stackView.spacing = theme.stackViewSpacing
       footerView.addSubview(stackView)
       
       stackView.snp.makeConstraints {
        $0.top == theme.stackViewContentEdgeInsets.top
        $0.leading == theme.stackViewContentEdgeInsets.leading
        $0.bottom == theme.stackViewContentEdgeInsets.bottom
        $0.trailing == theme.stackViewContentEdgeInsets.trailing
      }
   }
}

extension SendAssetAndOptInTransactionInfoScreen {
   enum Event {
      case didTapContinue
   }
}
