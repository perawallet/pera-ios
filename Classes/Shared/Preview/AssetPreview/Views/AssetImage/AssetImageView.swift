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
//   AssetImageView.swift

import MacaroonUIKit
import UIKit

final class AssetImageView: View {
    private lazy var placeholderView = AssetImagePlaceholderView()
    private lazy var imageView = ImageView()

    func customize(
        _ theme: AssetImageViewTheme
    ) {
        addPlaceholder(theme)
        addImage(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension AssetImageView {
    func addPlaceholder(
        _ theme: AssetImageViewTheme
    ) {
        placeholderView.customize(theme.placeholder)

        placeholderView.fitToIntrinsicSize()
        addSubview(placeholderView)
        placeholderView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    func addImage(
        _ theme: AssetImageViewTheme
    ) {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension AssetImageView {
    func prepareForReuse() {
        placeholderView.prepareForReuse()
        imageView.image = nil
    }
}

extension AssetImageView: ViewModelBindable {
    func bindData(_ viewModel: AssetImageViewModel?) {
        if let image = viewModel?.image {
            imageView.image = image
            return
        }

        placeholderView.bindData(viewModel)
    }
}
