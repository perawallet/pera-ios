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
//  AccountRecoverView.swift

import UIKit

class AccountRecoverView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var horizontalStackView: HStackView = {
        let stackView = HStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.spacing = 20.0
        stackView.alignment = .leading
        stackView.clipsToBounds = true
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .horizontal
        stackView.isUserInteractionEnabled = true
        return stackView
    }()

    private lazy var firstColumnStackView: VStackView = {
        let stackView = VStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.spacing = 8.0
        stackView.alignment = .fill
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = true
        return stackView
    }()

    private lazy var secondColumnStackView: VStackView = {
        let stackView = VStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.spacing = 8.0
        stackView.alignment = .fill
        stackView.clipsToBounds = true
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = true
        return stackView
    }()

    override func prepareLayout() {
        setupStackViewLayout()
    }
}

extension AccountRecoverView {
    private func setupStackViewLayout() {
        addSubview(horizontalStackView)

        horizontalStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }

        horizontalStackView.addArrangedSubview(firstColumnStackView)
        horizontalStackView.addArrangedSubview(secondColumnStackView)
    }
}

extension AccountRecoverView {
    func addInputViewToFirstColumn(_ view: RecoverInputView) {
        firstColumnStackView.addArrangedSubview(view)
    }

    func addInputViewToSecondColumn(_ view: RecoverInputView) {
        secondColumnStackView.addArrangedSubview(view)
    }
}

extension AccountRecoverView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 16.0
        let horizontalInset: CGFloat = 20.0
    }
}
