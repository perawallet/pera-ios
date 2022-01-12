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
//  HeaderView.swift

import UIKit
import MacaroonUIKit

final class HeaderView: View {
    lazy var handlers = Handlers()

    private lazy var theme = HeaderViewTheme()
    
    private lazy var titleLabel = Label()
    private lazy var testNetLabel = Label()
    private lazy var rightButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
        customize(theme)
    }

    func setListeners() {
        rightButton.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
    }

    func customize(_ theme: HeaderViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addRightButton(theme)
        addTitleLabel(theme)
        addTestNetLabel(theme)
    }

    func prepareLayout(_ layoutSheet: HeaderViewTheme) {}

    func customizeAppearance(_ styleSheet: HeaderViewTheme) {}
}

extension HeaderView {
    private func addRightButton(_ theme: HeaderViewTheme) {
        addSubview(rightButton)
        rightButton.snp.makeConstraints {
            $0.setPaddings(theme.rightButtonPaddings)
        }
    }

    private func addTitleLabel(_ theme: HeaderViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.setPaddings(theme.titlePaddings)
        }
    }

    private func addTestNetLabel(_ theme: HeaderViewTheme) {
        testNetLabel.customizeAppearance(theme.testNetTitleLabel)
        testNetLabel.draw(corner: theme.testNetTitleLabelCorner)

        addSubview(testNetLabel)
        testNetLabel.isHidden = true

        testNetLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(theme.testNetLabelOffset)
            $0.centerY.equalTo(titleLabel)
            $0.fitToSize(theme.testNetLabelSize)
        }
    }
}

extension HeaderView {
    func setTestNetLabelHidden(_ hidden: Bool) {
        testNetLabel.isHidden = hidden
    }

    func bindData(_ viewModel: HeaderViewModel) {
        titleLabel.text = viewModel.title
        if let rightButtonImage = viewModel.rightButtonImage {
            rightButton.setImage(rightButtonImage, for: .normal)
        } else {
            rightButton.isHidden = true
        }
    }
}

extension HeaderView {
    @objc
    private func didTapRightButton() {
        handlers.didTapRightButton?()
    }
}

extension HeaderView {
    struct Handlers {
        var didTapRightButton: EmptyHandler?
    }
}
