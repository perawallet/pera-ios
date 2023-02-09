// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SettingsPrimaryDetailView.swift

import MacaroonUIKit
import UIKit

final class SettingsPrimaryDetailView: View {
    private lazy var imageView = UIImageView()
    private lazy var titleView = PrimaryTitleView()
    private lazy var accessoryView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customize(SettingsPrimaryDetailViewTheme())
    }
    
    private func customize(_ theme: SettingsPrimaryDetailViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addImage(theme)
        addTitle(theme)
        addAccessory(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension SettingsPrimaryDetailView {
    private func addImage(_ theme: SettingsPrimaryDetailViewTheme) {
        imageView.customizeAppearance(theme.image)
        
        addSubview(imageView)
        imageView.fitToIntrinsicSize()
        imageView.snp.makeConstraints {
            $0.fitToSize(theme.imageSize)
            $0.top == theme.topInset
            $0.leading == theme.horizontalInset
        }
    }
    
    private func addTitle(_ theme: SettingsPrimaryDetailViewTheme) {
        titleView.customize(theme.title)
        
        addSubview(titleView)
        titleView.fitToHorizontalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == imageView
            $0.leading == imageView.snp.trailing + theme.titleOffset
            $0.bottom <= 0
        }
    }
    
    private func addAccessory(_ theme: SettingsPrimaryDetailViewTheme) {
        accessoryView.customizeAppearance(theme.accessory)
        
        addSubview(accessoryView)
        accessoryView.fitToIntrinsicSize()
        accessoryView.snp.makeConstraints {
            $0.fitToSize(theme.imageSize)
            $0.centerY == titleView
            $0.leading >= titleView.snp.trailing
            $0.trailing == theme.horizontalInset
        }
    }
}

extension SettingsPrimaryDetailView {
    func bindData(_ viewModel: PrimaryTitleViewModel) {
        titleView.bindData(viewModel)
    }
}
