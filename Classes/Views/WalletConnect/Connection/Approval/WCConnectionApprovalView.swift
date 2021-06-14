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
//   WCConnectionApprovalView.swift

import UIKit
import Macaroon

class WCConnectionApprovalView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCConnectionApprovalViewDelegate?

    private lazy var dappImageView = URLImageView()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(Colors.Text.secondary)
            .withFont(UIFont.font(withWeight: .regular(size: 18.0)))
    }()

    private lazy var verifiedImageView = UIImageView(image: img("icon-verified"))

    private lazy var urlLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(Colors.Text.link)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()

    private lazy var accountSelectionView = WCConnectionAccountSelectionView()

    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-cancel".localized)
            .withAlignment(.center)
            .withTitleColor(Colors.ButtonText.secondary)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withBackgroundImage(img("bg-button-secondary-small"))
    }()

    private lazy var connectButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-connect".localized)
            .withAlignment(.center)
            .withTitleColor(Colors.ButtonText.primary)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withBackgroundImage(img("bg-button-primary-small"))
    }()

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupDappImageViewLayout()
        setupTitleLabelLayout()
        setupVerifiedImageViewLayout()
        setupURLLabelLayout()
        setupAccountSelectionViewLayout()
        setupConnectButtonLayout()
        setupCancelButtonLayout()
    }

    override func linkInteractors() {

    }

    override func setListeners() {
        connectButton.addTarget(self, action: #selector(notifyDelegateToApproveConnection), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(notifyDelegateToRejectConnection), for: .touchUpInside)
    }
}

extension WCConnectionApprovalView {
    private func setupDappImageViewLayout() {
        addSubview(dappImageView)

        dappImageView.snp.makeConstraints { _ in

        }
    }

    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { _ in

        }
    }

    private func setupVerifiedImageViewLayout() {
        addSubview(verifiedImageView)

        verifiedImageView.snp.makeConstraints { _ in

        }
    }

    private func setupURLLabelLayout() {
        addSubview(urlLabel)

        urlLabel.snp.makeConstraints { _ in

        }
    }

    private func setupAccountSelectionViewLayout() {
        addSubview(accountSelectionView)

        accountSelectionView.snp.makeConstraints { _ in

        }
    }

    private func setupConnectButtonLayout() {
        addSubview(connectButton)

        connectButton.snp.makeConstraints { _ in

        }
    }

    private func setupCancelButtonLayout() {
        addSubview(cancelButton)

        cancelButton.snp.makeConstraints { _ in

        }
    }
}

extension WCConnectionApprovalView {
    @objc
    private func notifyDelegateToApproveConnection() {
        delegate?.wcConnectionApprovalViewDidApproveConnection(self)
    }

    @objc
    private func notifyDelegateToRejectConnection() {
        delegate?.wcConnectionApprovalViewDidRejectConnection(self)
    }

    @objc
    private func notifyDelegateToOpenAccountSelection() {
        delegate?.wcConnectionApprovalViewDidSelectAccountSelection(self)
    }
}

extension WCConnectionApprovalView {
    func bind(_ viewModel: WCConnectionApprovalViewModel) {
        dappImageView.load(from: viewModel.image)
        titleLabel.attributedText = viewModel.description
        verifiedImageView.isHidden = !viewModel.isVerified
        urlLabel.text = viewModel.urlString

        if let accountSelectionViewModel = viewModel.connectionAccountSelectionViewModel {
            accountSelectionView.bind(accountSelectionViewModel)
        }
    }

    func bind(_ viewModel: WCConnectionAccountSelectionViewModel) {
        accountSelectionView.bind(viewModel)
    }
}

extension WCConnectionApprovalView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
    }
}

protocol WCConnectionApprovalViewDelegate: AnyObject {
    func wcConnectionApprovalViewDidApproveConnection(_ wcConnectionApprovalView: WCConnectionApprovalView)
    func wcConnectionApprovalViewDidRejectConnection(_ wcConnectionApprovalView: WCConnectionApprovalView)
    func wcConnectionApprovalViewDidSelectAccountSelection(_ wcConnectionApprovalView: WCConnectionApprovalView)
}
