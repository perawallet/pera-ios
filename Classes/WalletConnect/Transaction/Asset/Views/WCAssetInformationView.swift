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
//   WCAssetInformationView.swift

import UIKit
import MacaroonUIKit

final class WCAssetInformationView:
    View,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performAction: GestureInteraction(),
    ]
    
    private lazy var titleLabel = UILabel()
    private lazy var assetBackgroundView = UIView()
    private lazy var detailStackView = HStackView()
    private lazy var verificationTierIcon = UIImageView()
    private lazy var assetLabel = UILabel()

    func customize(_ theme: WCAssetInformationViewTheme) {
        addTitle(theme)
        addDetail(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension WCAssetInformationView {
    private func addTitle(
        _ theme: WCAssetInformationViewTheme
    ) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
    }
    
    private func addDetail(
        _ theme: WCAssetInformationViewTheme
    ) {
        addSubview(assetBackgroundView)
        assetBackgroundView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(theme.detailLabelLeadingPadding)
            $0.trailing.lessThanOrEqualToSuperview()
        }

        detailStackView.spacing = theme.spacing

        assetBackgroundView.addSubview(detailStackView)
        detailStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        assetLabel.customizeAppearance(theme.asset)

        detailStackView.addArrangedSubview(verificationTierIcon)
        detailStackView.addArrangedSubview(assetLabel)

        startPublishing(
            event: .performAction,
            for: assetBackgroundView
        )
    }
}

extension WCAssetInformationView: ViewModelBindable {
    func bindData(
        _ viewModel: WCAssetInformationViewModel?
    ) {
        guard let viewModel = viewModel else {
            return
        }

        if let title = viewModel.title {
            titleLabel.text = title
        }

        if let name = viewModel.name {
            if let assetId = viewModel.assetId {
                assetLabel.text = "\(name) \(assetId)"
                assetLabel.textColor = viewModel.nameColor?.uiColor
            } else {
                assetLabel.text = name
                assetLabel.textColor = viewModel.nameColor?.uiColor
            }
        }

        verificationTierIcon.image = viewModel.verificationTierIcon
    }
}

extension WCAssetInformationView {
    enum Event {
        case performAction
    }
}
