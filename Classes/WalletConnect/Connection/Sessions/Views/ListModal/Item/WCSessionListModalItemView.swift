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
//   WCSessionListModalItemView.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class WCSessionListModalItemView: View {
    weak var delegate: WCSessionListModalItemViewDelegate?

    private lazy var dappImageView = URLImageView()
    private lazy var nameLabel = UILabel()
    private lazy var disconnectOptionsButton = UIButton()
    private lazy var descriptionLabel = UILabel()

     func setListeners() {
        disconnectOptionsButton.addTarget(self, action: #selector(notifyDelegateToOpenDisconnectionMenu), for: .touchUpInside)
    }

    func customize(_ theme: WCSessionsListModalItemViewTheme) {
        addDappImageView(theme)
        addDisconnectOptionsButton(theme)
        addNameLabel(theme)
        addDescriptionLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension WCSessionListModalItemView {
    private func addDappImageView(_ theme: WCSessionsListModalItemViewTheme) {
        dappImageView.draw(border: theme.imageBorder)
        dappImageView.draw(corner: theme.imageCorner)

        addSubview(dappImageView)
        dappImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(theme.imageVerticalInset)
        }
    }

    private func addDisconnectOptionsButton(_ theme: WCSessionsListModalItemViewTheme) {
        disconnectOptionsButton.customizeAppearance(theme.disconnectOptionsButton)

        addSubview(disconnectOptionsButton)
        disconnectOptionsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.fitToSize(theme.disconnectOptionsButtonSize)
            $0.centerY.equalToSuperview()
        }
    }

    private func addNameLabel(_ theme: WCSessionsListModalItemViewTheme) {
        nameLabel.customizeAppearance(theme.nameLabel)

        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(dappImageView.snp.trailing).offset(theme.nameLabelHorizontalInset)
            $0.trailing.lessThanOrEqualTo(disconnectOptionsButton.snp.leading).offset(-theme.nameLabelHorizontalInset)
            $0.top.equalToSuperview()
        }
    }

    private func addDescriptionLabel(_ theme: WCSessionsListModalItemViewTheme) {
        descriptionLabel.customizeAppearance(theme.descriptionLabel)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(theme.descriptionTopInset)
            $0.trailing.lessThanOrEqualTo(disconnectOptionsButton.snp.leading).inset(theme.horizontalInset)
            $0.bottom.equalToSuperview()
        }
    }
}

extension WCSessionListModalItemView {
    @objc
    private func notifyDelegateToOpenDisconnectionMenu() {
        delegate?.wcSessionListModalItemViewDidOpenDisconnectionMenu(self)
    }
}

extension WCSessionListModalItemView: ViewModelBindable {
    func bindData(_ viewModel: WCSessionsListModalItemViewModel?) {
        dappImageView.load(from: viewModel?.image)
        nameLabel.text = viewModel?.name
        descriptionLabel.text = viewModel?.description
    }

    func prepareForReuse() {
        dappImageView.prepareForReuse()
        nameLabel.text = nil
        descriptionLabel.text = nil
    }
}

protocol WCSessionListModalItemViewDelegate: AnyObject {
    func wcSessionListModalItemViewDidOpenDisconnectionMenu(_ wcSessionListModalView: WCSessionListModalItemView)
}
