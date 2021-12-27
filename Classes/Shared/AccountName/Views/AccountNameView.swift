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
//  AccountNameView.swift

import UIKit
import MacaroonUIKit

final class AccountNameView: View {
    private lazy var imageView = UIImageView()
    private lazy var nameLabel = UILabel()

    func customize(_ theme: AccountNameViewTheme) {
        addImageView(theme)
        addNameLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension AccountNameView {
    private func addImageView(_ theme: AccountNameViewTheme) {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.bottom.top.equalToSuperview()
            $0.fitToSize(theme.imageSize)
        }
    }
    
    private func addNameLabel(_ theme: AccountNameViewTheme) {
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.horizontalPadding)
            $0.centerY.trailing.equalToSuperview()
        }
    }
}

extension AccountNameView: ViewModelBindable {
    func bindData(_ viewModel: AccountNameViewModel?) {
        imageView.image = viewModel?.image
        nameLabel.text = viewModel?.name
    }
}

extension AccountNameView {
    func setAccountImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setAccountName(_ name: String?) {
        nameLabel.text = name
    }
}
