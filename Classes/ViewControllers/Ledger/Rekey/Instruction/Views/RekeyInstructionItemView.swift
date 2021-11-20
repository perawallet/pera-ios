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
//  RekeyInstructionItemView.swift

import UIKit
import MacaroonUIKit

final class RekeyInstructionItemView: View {
    private lazy var informationImageView = UIImageView()
    private lazy var titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(RekeyInstructionItemViewTheme())
    }

    func customize(_ theme: RekeyInstructionItemViewTheme) {
        addInformationImageView(theme)
        addTitleLabel(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension RekeyInstructionItemView {
    private func addInformationImageView(_ theme: RekeyInstructionItemViewTheme) {
        informationImageView.customizeAppearance(theme.image)

        addSubview(informationImageView)
        informationImageView.snp.makeConstraints {
            $0.leading.centerY.bottom.top.equalToSuperview()
            $0.fitToSize(theme.infoImageSize)
        }
    }
    
    private func addTitleLabel(_ theme: RekeyInstructionItemViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(informationImageView.snp.trailing).offset(theme.horizontalPadding)
            $0.centerY.equalTo(informationImageView)
            $0.trailing.equalToSuperview()
        }
    }
}

extension RekeyInstructionItemView {
    func bindTitle(_ title: String?) {
        titleLabel.text = title
    }
}
