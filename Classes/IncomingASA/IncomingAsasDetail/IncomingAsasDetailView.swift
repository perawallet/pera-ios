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

final class IncomingAsasDetailView: 
    View,
    ViewModelBindable,
    UIInteractable {

    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performCopy: TargetActionInteraction(),
        .performClose: TargetActionInteraction()
    ]

    private lazy var theme = IncomingAsasDetailViewTheme()
    
    private(set) lazy var scrollView: UIScrollView = {
        let scrollView = ScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private(set) lazy var contentView: UIView = {
        let contentView = UIView()
        return contentView
    }()

    private lazy var accountAssetsView = IncomingASAAccountView()
    
    private lazy var titleView = Label()
    private lazy var closeActionView = MacaroonUIKit.Button()

    private lazy var assetValueView = UILabel()
    private lazy var amountValueView = UILabel()
    private lazy var idView = UILabel()
    private lazy var copyActionView = UIButton()
    private lazy var sendersTitleView = UILabel()
    private lazy var amountTitleView = UILabel()
    private lazy var sendersContextView = MacaroonUIKit.VStackView()
    private lazy var infoFooterView = UILabel()

    private var sendersTheme: IncomingAsaSenderViewTheme?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customize(theme)
    }
    
    func customize(_ theme: IncomingAsasDetailViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        addAccountAssetsView(theme.accountAssetsTheme)
        addScroll(theme)
        addContent(theme)
        addCloseAction(theme.titleCloseAction)
        addAssetValueView(theme.amount)
        addAmountValueView(theme.amount)
        addCopyActionView(theme.copy)
        addIdView(theme.copy)
        addSendersTitle(theme)
        addAmountTitle(theme)
        addSendersContextView()
        sendersTheme = theme.senders
        addInfoFooterView(theme)
    }

    func bindData(_ viewModel: IncomingAsasDetailViewModel?) {
        accountAssetsView.bindData(viewModel?.accountAssets)
        "Asset Transfer Request".load(in: titleView)
        
        if let title = viewModel?.amount?.title {
            title.load(in: assetValueView)
        } else {
            assetValueView.text = nil
            assetValueView.attributedText = nil
        }

        if let subTitle = viewModel?.amount?.subTitle {
            subTitle.load(in: amountValueView)
        } else {
            amountValueView.text = nil
            amountValueView.attributedText = nil
        }

        if let id = viewModel?.id {
            id.load(in: idView)
        } else {
            idView.clearText()
        }
        
        "Amount".load(in: amountTitleView)
        "Senders".load(in: sendersTitleView)
        
        sendersContextView.deleteAllArrangedSubviews()
        
        viewModel?.senders?.forEach({ vm in
            addSenderItem(vm, sendersTheme)
        })
        
        "You will receive 0.22 ALGO in order to compensate the opt-in expenses.".load(in: infoFooterView)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension IncomingAsasDetailView {
    
    private func addAccountAssetsView(_ theme: IncomingASAAccountTheme) {
        addSubview(accountAssetsView)
        accountAssetsView.customize(theme)
        
        accountAssetsView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(64)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(200)
        }
    }

    private func addScroll(_ theme: IncomingAsasDetailViewTheme) {
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addContent(_ theme: IncomingAsasDetailViewTheme) {
        contentView.customizeBaseAppearance(backgroundColor: theme.contentBackground)
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width == self
            $0.top == 200
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
//            $0.height.equalToSuperview().priority(.low)
        }
        contentView.roundTheCorners([.topLeft, .topRight], radius: 15)
        
        
        let dragIndicatorView = UIView()
        dragIndicatorView.customizeBaseAppearance(backgroundColor: theme.dragIndicatorBackground)
        contentView.addSubview(dragIndicatorView)
        dragIndicatorView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topInset)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(theme.dragIndicatorHeight)
            $0.width.equalTo(theme.dragIndicatorWidth)
        }
    }
    
    private func addCloseAction(
        _ theme: IncomingAsaRequestTitleTheme
    ) {
        closeActionView.customizeAppearance(theme.action)

        contentView.addSubview(closeActionView)
        closeActionView.fitToHorizontalIntrinsicSize()
        closeActionView.snp.makeConstraints {
            $0.setPaddings(theme.closeActionViewPaddings)
        }

        startPublishing(
            event: .performClose,
            for: closeActionView
        )

        addTitle(theme)
    }

    private func addTitle(
        _ theme: IncomingAsaRequestTitleTheme
    ) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.centerY == closeActionView
            $0.centerX == 0
            $0.leading >= closeActionView.snp.trailing + theme.titleViewHorizontalPaddings.leading
            $0.trailing <= theme.titleViewHorizontalPaddings.trailing
        }
    }

}

extension IncomingAsasDetailView {
    private func addAssetValueView(_ theme: IncomingAsaRequestHeaderTheme) {
        assetValueView.customizeAppearance(theme.title)

        contentView.addSubview(assetValueView)
        assetValueView.fitToIntrinsicSize()
        assetValueView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(theme.titleTopPadding)
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addAmountValueView(_ theme: IncomingAsaRequestHeaderTheme) {
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

extension IncomingAsasDetailView {
    
    private func addCopyActionView(_ theme: IncomingASARequestIdTheme) {
        copyActionView.customizeAppearance(theme.action)

        contentView.addSubview(copyActionView)
        copyActionView.snp.makeConstraints {
            $0.trailing == 20
            $0.top.equalTo(amountValueView.snp.bottom).offset(53)
            $0.height.equalTo(32)
        }
        
        copyActionView.contentEdgeInsets = UIEdgeInsets(theme.primaryActionContentEdgeInsets)
        copyActionView.layer.cornerRadius = 15
        copyActionView.layer.masksToBounds = true
        
        startPublishing(
            event: .performCopy,
            for: copyActionView
        )

    }

    func addIdView(_ theme: IncomingASARequestIdTheme) {
        contentView.addSubview(idView)
        idView.snp.makeConstraints {
            $0.leading == 20
            $0.centerY.equalTo(copyActionView.snp.centerY)
        }
        
        idView.customizeAppearance(theme.id)
        
        
        let seperator = UIView()
        addSubview(seperator)
        seperator.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
            $0.top.equalTo(copyActionView.snp.bottom).offset(16)
        }
        seperator.customizeAppearance(theme.dividerLine)
    }

}

extension IncomingAsasDetailView {
    
    private func addSendersTitle(_ theme: IncomingAsasDetailViewTheme) {
        sendersTitleView.customizeAppearance(theme.sendersTitle)
        
        contentView.addSubview(sendersTitleView)
        sendersTitleView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(copyActionView.snp.bottom).offset(41)
        }
    }
    
    private func addAmountTitle(_ theme: IncomingAsasDetailViewTheme) {
        amountTitleView.customizeAppearance(theme.amountTitle)
        
        contentView.addSubview(amountTitleView)
        amountTitleView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(copyActionView.snp.bottom).offset(41)
        }
    }
}

extension IncomingAsasDetailView {
    
    private func addSendersContextView() {
        contentView.addSubview(sendersContextView)
        sendersContextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(amountTitleView.snp.bottom).offset(16)
        }
    }

    private func addSenderItem(
        _ vm: IncomingAsaSenderViewModel,
        _ theme: IncomingAsaSenderViewTheme?
    ) {
        let itemView = createSenderItemView(
            vm,
            theme
        )
        sendersContextView.addArrangedSubview(itemView)
    }

    private func createSenderItemView(
        _ vm: IncomingAsaSenderViewModel,
        _ theme: IncomingAsaSenderViewTheme?
    ) -> IncomingAsaSenderView {
        let itemView = IncomingAsaSenderView()
        
        if let theme {
            itemView.customize(theme)
        }

        itemView.bindData(vm)

        return itemView
    }
}

extension IncomingAsasDetailView {
    private func addInfoFooterView(_ theme: IncomingAsasDetailViewTheme) {
        infoFooterView.customizeAppearance(theme.infoFooter)
        
        contentView.addSubview(infoFooterView)
        infoFooterView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(sendersContextView.snp.bottom).offset(32)
            $0.bottom.equalToSuperview().inset(120)
        }
    }
}

extension IncomingAsasDetailView {
    enum Event {
        case performCopy
        case performClose
    }
}
