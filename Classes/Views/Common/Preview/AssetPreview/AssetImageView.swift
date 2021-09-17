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
//   AssetImageView.swift

import Macaroon

final class AssetImageView: View {
    private lazy var theme = AssetImageViewTheme()
    private lazy var assetImageView = UIImageView()
    private lazy var assetNameLabel = UILabel()

    private var assetName: String? {
        didSet {
            addLabel(theme)
            addBorder(theme)
        }
    }
    
    private var image: UIImage? {
        didSet {
            addImage()
        }
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension AssetImageView {
    func addImage() {
        assetImageView.image = image

        addSubview(assetImageView)
        assetImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func addLabel(_ theme: AssetImageViewTheme) {
        assetNameLabel.customizeAppearance(theme.nameText)
        assetNameLabel.text = assetName

        addSubview(assetNameLabel)
        assetNameLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func addBorder(_ theme: AssetImageViewTheme) {
        draw(border: theme.border)
    }
}

extension AssetImageView: ViewModelBindable {
    func bindData(_ viewModel: AssetPreviewViewModel?) {
        if let assetName = viewModel?.assetName {
            self.assetName = assetName
        }

        if let image = viewModel?.image {
            self.image = image
        }
    }
}
