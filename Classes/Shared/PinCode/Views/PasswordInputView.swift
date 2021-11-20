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
//  PasswordInputView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class PasswordInputView: View {
    private lazy var theme = PasswordInputViewTheme()

    override var intrinsicContentSize: CGSize {
        return CGSize(theme.size)
    }
    
    private(set) var passwordInputCircleViews: [PasswordInputCircleView] = []
    private lazy var stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }

    func customize(_ theme: PasswordInputViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addStackView()
        addCircleViews()
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension PasswordInputView {
    private func addStackView() {
        stackView.distribution = .fillEqually
        stackView.alignment = .center

        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func addCircleViews() {
        for _ in 1...6 {
            let circleView = PasswordInputCircleView()
            passwordInputCircleViews.append(circleView)
            stackView.addArrangedSubview(circleView)
        }
    }
}
