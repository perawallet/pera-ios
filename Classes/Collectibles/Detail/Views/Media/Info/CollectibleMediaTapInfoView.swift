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

//   CollectibleMediaTapInfoView.swift

import UIKit
import MacaroonUIKit

final class CollectibleMediaTapInfoView: View {

    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        customize(CollectibleMediaTapInfoViewTheme())
    }

    func customize(
        _ theme: CollectibleMediaTapInfoViewTheme
    ) {
        addTitleLabel(theme)
        addImageView(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension CollectibleMediaTapInfoView {
    private func addTitleLabel(
        _ theme: CollectibleMediaTapInfoViewTheme
    ) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.trailing <= 0
            $0.centerY.equalToSuperview()
        }
    }

    private func addImageView(
        _ theme: CollectibleMediaTapInfoViewTheme
    ) {
        imageView.customizeAppearance(theme.image)

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.trailing == titleLabel.snp.leading - theme.iconOffset
            $0.top == 0
            $0.bottom == 0
        }
    }
}
