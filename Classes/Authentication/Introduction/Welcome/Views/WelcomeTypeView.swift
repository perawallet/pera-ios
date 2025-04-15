// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WelcomeTypeView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class WelcomeTypeView: Control {
    private lazy var theme = WelcomeTypeViewTheme()
    private lazy var contentView = UIView()
    private lazy var imageView = UIImageView()
    private lazy var arrowIconImageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var detailLabel = UILabel()
    private lazy var warningOverlayView = UIView()
    
    func customize(_ theme: WelcomeTypeViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addDetailLabel(theme)

        addContentView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension WelcomeTypeView {
    private func addDetailLabel(_ theme: WelcomeTypeViewTheme) {
        detailLabel.customizeAppearance(theme.detail)
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.detailHorizontalInset)
            $0.top.equalToSuperview()
            $0.height.equalTo(theme.detailHeight)
        }
    }

    private func addContentView(_ theme: WelcomeTypeViewTheme) {
        contentView.customizeAppearance(theme.contentView)
        contentView.layer.cornerRadius = 16
        addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).inset(theme.contentViewInsets.top)
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(theme.contentViewInsets.trailing)
            $0.leading.equalToSuperview().inset(theme.contentViewInsets.leading)
        }
        addImageView(theme)
        addTitleLabel(theme)
        addArrowIcon(theme)
    }
    private func addImageView(_ theme: WelcomeTypeViewTheme) {
        contentView.addSubview(imageView)
        imageView.isUserInteractionEnabled = false
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.iconInsets.top)
            $0.bottom.equalToSuperview().inset(theme.iconInsets.bottom)
            $0.leading.equalToSuperview().inset(theme.iconInsets.leading)
            $0.width.equalTo(theme.iconSize.w)
            $0.height.equalTo(theme.iconSize.h)
        }
    }

    private func addTitleLabel(_ theme: WelcomeTypeViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.titleHorizontalInset)
            $0.centerY.equalTo(contentView.snp.centerY)
        }
    }
    
    private func addArrowIcon(_ theme: WelcomeTypeViewTheme) {
        arrowIconImageView.customizeAppearance(theme.arrowIcon)
        
        contentView.addSubview(arrowIconImageView)
        arrowIconImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.arrowIconHorizontalInset)
            $0.centerY.equalTo(contentView.snp.centerY)
            $0.height.equalTo(theme.iconSize.h)
            $0.width.equalTo(theme.iconSize.w)
        }
    }
}

extension WelcomeTypeView: ViewModelBindable {
    func bindData(_ viewModel: WelcomeTypeViewModel?) {
        imageView.image = viewModel?.image
        titleLabel.editText = viewModel?.title
        detailLabel.editText = viewModel?.detail
    }
}
