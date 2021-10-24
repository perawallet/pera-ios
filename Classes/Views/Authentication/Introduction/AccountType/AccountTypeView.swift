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
//  AccountTypeView.swift

import UIKit
import Macaroon

final class AccountTypeView: Control {
    private lazy var theme = AccountTypeViewTheme()
    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var detailLabel = UILabel()

    func customize(_ theme: AccountTypeViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addImageView(theme)
        addTitleLabel(theme)
        addDetailLabel(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension AccountTypeView {
    private func addImageView(_ theme: AccountTypeViewTheme) {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.fitToSize(theme.iconSize)
            $0.centerY.equalToSuperview()
        }
    }

    private func addTitleLabel(_ theme: AccountTypeViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.verticalInset)
            $0.trailing.equalToSuperview().inset(theme.titleTrailingInset)
        }
    }

    private func addDetailLabel(_ theme: AccountTypeViewTheme) {
        detailLabel.customizeAppearance(theme.detail)

        addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(theme.titleTrailingInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.minimumInset)
            $0.bottom.equalToSuperview().offset(-theme.verticalInset)
        }

        detailLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(detailLabel.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupTypeImageViewLayout() {
        addSubview(typeImageView)
        
        typeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.iconSize)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupArrowImageViewLayout() {
        addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(typeImageView)
            make.size.equalTo(layout.current.arrowIconSize)
        }
    }

    private func addImageView(_ theme: AccountTypeViewTheme) {
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.fitToSize(theme.iconSize)
            $0.centerY.equalToSuperview()
        }
    }
}

extension AccountTypeView: ViewModelBindable {
    func bindData(_ viewModel: AccountTypeViewModel?) {
        imageView.image = viewModel?.image
        titleLabel.text = viewModel?.title
        detailLabel.text = viewModel?.detail
    }
}
