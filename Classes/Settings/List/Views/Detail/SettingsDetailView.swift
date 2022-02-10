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
//   SettingsDetailView.swift

import UIKit
import MacaroonUIKit

final class SettingsDetailView: View {
    private lazy var theme = SettingsDetailViewTheme()
    
    private lazy var imageView = UIImageView()
    private lazy var detailImageView = UIImageView()
    private lazy var nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }
    
    func customize(_ theme: SettingsDetailViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addImageView()
        addNameLabel()
        addDetailImageView()
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {
        addImageView()
        addNameLabel()
        addDetailImageView()
    }
}

extension SettingsDetailView {
    private func addImageView() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
        }
    }
    
    private func addNameLabel() {
        nameLabel.customizeAppearance(theme.name)
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.nameOffset)
        }
    }
    
    private func addDetailImageView() {
        detailImageView.customizeAppearance(theme.detail)
        addSubview(detailImageView)
        
        detailImageView.snp.makeConstraints {
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
}

extension SettingsDetailView {
    func bindData(_ viewModel: SettingsDetailViewModel) {
        nameLabel.text = viewModel.title
        imageView.image = viewModel.image
    }
}
