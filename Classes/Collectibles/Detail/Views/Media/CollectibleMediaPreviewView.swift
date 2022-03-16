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

//   CollectibleMediaPreviewView.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class CollectibleMediaPreviewView:
    View,
    ViewModelBindable,
    ListReusable {

    private lazy var image = URLImageView()

    func customize(
        _ theme: CollectibleMediaPreviewViewTheme
    ) {
        addImage(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension CollectibleMediaPreviewView {
    private func addImage(
        _ theme: CollectibleMediaPreviewViewTheme
    ) {
        image.customizeAppearance(theme.image)
        image.layer.draw(corner: theme.corner)
        image.clipsToBounds = true

        addSubview(image)
        image.fitToIntrinsicSize()
        image.snp.makeConstraints {
            $0.width == snp.width
            $0.height == image.snp.width
            $0.setPaddings((0, 0, .noMetric, 0))
        }
    }
}

extension CollectibleMediaPreviewView {
    func bindData(
        _ viewModel: CollectibleMediaPreviewViewModel?
    ) {
        image.load(from: viewModel?.image)
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleMediaPreviewViewModel?,
        for theme: CollectibleMediaPreviewViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let iconHeight = size.width
        return CGSize((size.width, min(iconHeight.ceil(), size.height)))
    }
}

extension CollectibleMediaPreviewView {
    func prepareForReuse() {
        image.prepareForReuse()
    }
}
