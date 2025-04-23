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

//   IncomingAsasDetailView.swift

import UIKit
import MacaroonUIKit

final class IncomingASAsDetailView: 
    View,
    ViewModelBindable,
    UIInteractable {

    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performCopy: TargetActionInteraction(),
        .performClose: TargetActionInteraction()
    ]
    private(set) lazy var contentView = UIView()
    
    private lazy var theme = IncomingASAsDetailViewTheme()
    private lazy var accountView = IncomingASADetailAccountView()
    private lazy var assetValueView = UILabel()
    private lazy var amountValueView = UILabel()
    private lazy var idView = UILabel()
    private lazy var copyActionView = UIButton()
    private lazy var sendersTitleView = UILabel()
    private lazy var amountTitleView = UILabel()
    private lazy var sendersContextView = MacaroonUIKit.VStackView()
    private lazy var infoFooterView = UILabel()
    private lazy var infoFooterIcon = UIImageView()

    private var sendersTheme: IncomingASARequesSenderViewTheme?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customize(theme)
    }
    
    func customize(_ theme: IncomingASAsDetailViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.contentBackground)
        addContent(theme)
        addAssetValueView(theme.amount)
        addAmountValueView(theme.amount)
        addCopyActionView(theme.copy)
        addIdView(theme.copy)
        addAccountView(theme.accountViewTheme)
        addSendersTitle(theme)
        addAmountTitle(theme)
        addSendersContextView(theme)
        sendersTheme = theme.senders
        addInfoFooterView(theme)
    }

    func bindData(_ viewModel: IncomingASAsDetailViewModel?) {
        accountView.bindData(viewModel?.accountItem)
        
        if let collectibleViewModel = viewModel?.draft.collectibleViewModel {
            if let title = collectibleViewModel.primaryTitle {                
                title
                    .string
                    .titleMedium(
                        alignment: .center
                    )
                    .load(in: assetValueView)
            } else {
                clearView(assetValueView)
            }
            
            if let subtitle = collectibleViewModel.secondaryTitle {
                subtitle.string.footnoteRegular(alignment: .center)
                    .load(in: amountValueView)
            } else {
                clearView(amountValueView)
            }

        } else {
            if let title = viewModel?.amount?.title {
                title.load(in: assetValueView)
            } else {
                clearView(assetValueView)
            }

            if let subTitle = viewModel?.amount?.subTitle {
                subTitle.load(in: amountValueView)
            } else {
                clearView(amountValueView)
            }
        }

        if let id = viewModel?.accountId {
            id.load(in: idView)
        } else {
            idView.clearText()
        }
        
        String(localized: "transaction-detail-amount")
            .load(in: amountTitleView)
        
        String(localized: "incoming-asa-detail-screen-senders-title")
            .load(in: sendersTitleView)
        
        sendersContextView.deleteAllArrangedSubviews()
        
        viewModel?.senders?.forEach({ vm in
            addSenderItem(vm, sendersTheme)
        })
        
        String(format: String(localized: "incoming-asa-detail-screen-description_accept"), viewModel?.algoGainOnClaim?.toAlgos.stringValue ?? "")
            .load(in: infoFooterView)
    }
    
    private func clearView(_ view: UILabel) {
        view.text = nil
        view.attributedText = nil
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension IncomingASAsDetailView {
    
    private func addAccountView(_ theme: IncomingASADetailAccountViewTheme) {
        addSubview(accountView)
        accountView.customize(theme)

        accountView.snp.makeConstraints {
            $0.top.equalTo(idView.snp.bottom).offset(45)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.height.equalTo(theme.height)
        }
        
        let seperator = UIView()
        addSubview(seperator)
        seperator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.idSeperatorPadding)
            $0.height.equalTo(theme.dividerLineHeight)
            $0.top.equalTo(accountView.snp.bottom).offset(theme.idSeperatorPadding)
        }
        seperator.customizeAppearance(theme.dividerLine)
    }

    private func addContent(_ theme: IncomingASAsDetailViewTheme) {
        contentView.customizeBaseAppearance(backgroundColor: theme.contentBackground)
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }        
    }
}

extension IncomingASAsDetailView {
    private func addAssetValueView(_ theme: IncomingASARequestHeaderTheme) {
        assetValueView.customizeAppearance(theme.title)

        contentView.addSubview(assetValueView)
        assetValueView.fitToIntrinsicSize()
        assetValueView.snp.makeConstraints {
            $0.top.greaterThanOrEqualToSuperview().offset(theme.assetValueTopPadding)
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addAmountValueView(_ theme: IncomingASARequestHeaderTheme) {
        amountValueView.customizeAppearance(theme.subtitle)
        

        contentView.addSubview(amountValueView)
        amountValueView.fitToIntrinsicSize()
        amountValueView.snp.makeConstraints {
            $0.top == assetValueView.snp.bottom + theme.spacingBetweenTitleAndSubtitle
            $0.leading == 0
            $0.trailing == 0
        }
    }
}

extension IncomingASAsDetailView {
    
    private func addCopyActionView(_ theme: IncomingASARequestIdTheme) {
        copyActionView.customizeAppearance(theme.action)

        contentView.addSubview(copyActionView)
        copyActionView.snp.makeConstraints {
            $0.trailing == theme.copyActionRightInset
            $0.top.greaterThanOrEqualTo(amountValueView.snp.bottom).offset(theme.copyActionBottomInset)
            $0.height.equalTo(theme.copyActionHeight)
        }
        
        copyActionView.contentEdgeInsets = UIEdgeInsets(theme.primaryActionContentEdgeInsets)
        copyActionView.layer.cornerRadius = theme.copyActionCorner
        copyActionView.layer.masksToBounds = true
        
        startPublishing(
            event: .performCopy,
            for: copyActionView
        )

    }

    func addIdView(_ theme: IncomingASARequestIdTheme) {
        contentView.addSubview(idView)
        idView.snp.makeConstraints {
            $0.leading == theme.idLeftInset
            $0.centerY.equalTo(copyActionView.snp.centerY)
        }
        
        idView.customizeAppearance(theme.id)
        
        let seperator = UIView()
        addSubview(seperator)
        seperator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.idSeperatorPadding)
            $0.height.equalTo(theme.dividerLineHeight)
            $0.top.equalTo(copyActionView.snp.bottom).offset(theme.idSeperatorPadding)
        }
        seperator.customizeAppearance(theme.dividerLine)
    }

}

extension IncomingASAsDetailView {
    
    private func addSendersTitle(_ theme: IncomingASAsDetailViewTheme) {
        sendersTitleView.customizeAppearance(theme.sendersTitle)
        
        contentView.addSubview(sendersTitleView)
        sendersTitleView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.amountTrailingInset)
            $0.top.equalTo(accountView.snp.bottom).offset(theme.amountTopInset)
        }
    }
    
    private func addAmountTitle(_ theme: IncomingASAsDetailViewTheme) {
        amountTitleView.customizeAppearance(theme.amountTitle)
        
        contentView.addSubview(amountTitleView)
        amountTitleView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.amountTrailingInset)
            $0.top.equalTo(accountView.snp.bottom).offset(theme.amountTopInset)
        }
    }
}

extension IncomingASAsDetailView {
    
    private func addSendersContextView(_ theme: IncomingASAsDetailViewTheme) {
        contentView.addSubview(sendersContextView)
        sendersContextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.sendersContextPadding)
            $0.top.equalTo(amountTitleView.snp.bottom).offset(theme.sendersContextTopInset)
        }
        
        sendersContextView.spacing = 16
    }

    private func addSenderItem(
        _ vm: IncomingASARequesSenderViewModel,
        _ theme: IncomingASARequesSenderViewTheme?
    ) {
        let itemView = createSenderItemView(
            vm,
            theme
        )
        sendersContextView.addArrangedSubview(itemView)
    }

    private func createSenderItemView(
        _ vm: IncomingASARequesSenderViewModel,
        _ theme: IncomingASARequesSenderViewTheme?
    ) -> IncomingASARequesSenderView {
        let itemView = IncomingASARequesSenderView()
        
        if let theme {
            itemView.customize(theme)
        }

        itemView.bindData(vm)

        return itemView
    }
}

extension IncomingASAsDetailView {
    private func addInfoFooterView(_ theme: IncomingASAsDetailViewTheme) {
        
        infoFooterIcon.customizeAppearance(theme.infoIcon)
        contentView.addSubview(infoFooterIcon)
        infoFooterIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.infoFooterPadding)
            $0.top.equalTo(sendersContextView.snp.bottom).offset(theme.infoFooterTopInset)
        }
        
        infoFooterView.customizeAppearance(theme.infoFooter)
        contentView.addSubview(infoFooterView)
        infoFooterView.snp.makeConstraints {
            $0.leading.equalTo(infoFooterIcon.snp.trailing).offset(theme.infoFooterLeadingInset)
            $0.trailing.equalToSuperview().inset(theme.infoFooterPadding)
            $0.top.equalTo(sendersContextView.snp.bottom).offset(theme.infoFooterTopInset)
            $0.bottom.equalToSuperview().inset(theme.infoFooterBottomInset)
        }
    }
}

extension IncomingASAsDetailView {
    enum Event {
        case performCopy
        case performClose
    }
}
