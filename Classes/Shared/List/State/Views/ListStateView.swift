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
//   ListStateView.swift

import UIKit
import MacaroonUIKit

final class ListStateView: View {
    private lazy var stackView = VStackView()
    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var detailLabel = UILabel()
    private lazy var actionButton = Button()

    lazy var handlers = Handlers()

    override init(frame: CGRect) {
        super.init(frame: frame)
        customize(ListStateViewTheme())
    }

    func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDidSelectedAction), for: .touchUpInside)
    }

    func customize(_ theme: ListStateViewTheme) {
        addStackView(theme)
        addImageView(theme)
        addTitleabel(theme)
        addDetailLabel(theme)
        addActionButton(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension ListStateView {
    private func addStackView(_ theme: ListStateViewTheme) {
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = theme.stackSpacing

        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addImageView(_ theme: ListStateViewTheme) {
        imageView.customizeAppearance(theme.icon)
        stackView.addArrangedSubview(imageView)
    }

    private func addTitleabel(_ theme: ListStateViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(theme.detailTopPadding, after: titleLabel)
    }

    private func addDetailLabel(_ theme: ListStateViewTheme) {
        detailLabel.customizeAppearance(theme.detail)
        stackView.addArrangedSubview(detailLabel)
    }

    private func addActionButton(_ theme: ListStateViewTheme) {
        actionButton.customize(theme.action)
        stackView.addArrangedSubview(imageView)
    }
}

extension ListStateView {
    @objc
    private func notifyDidSelectedAction() {
        handlers.didSelectAction?()
    }
}

extension ListStateView: ViewModelBindable {
    func bindData(_ viewModel: ListStateViewModel?) {
        imageView.image = viewModel?.icon?.uiImage
        titleLabel.editText = viewModel?.title
        detailLabel.editText = viewModel?.detail
        actionButton.setEditTitle(viewModel?.actionTitle, for: .normal)
    }
}

extension ListStateView {
    struct Handlers {
        var didSelectAction: EmptyHandler?
    }
}
