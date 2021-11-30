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
//   TabBarModalView.swift

import UIKit
import MacaroonUIKit

final class TabBarModalView: View {
    private(set) lazy var sendButton = UIButton()
    private lazy var sendLabel = UILabel()
    private(set) lazy var receiveButton = UIButton()
    private lazy var receiveLabel = UILabel()

    func customize(_ theme: TabBarModalViewTheme) {
        draw(corner: theme.corner)
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addSendButton(theme)
        addSendLabel(theme)
        addReceiveButton(theme)
        addReceiveLabel(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension TabBarModalView {
    private func addSendButton(_ theme: TabBarModalViewTheme) {
        sendButton.customizeAppearance(theme.sendButton)

        addSubview(sendButton)
        sendButton.snp.makeConstraints {
            $0.trailing == snp.centerX - theme.horizontalPadding
            $0.centerY == 0
        }
    }

    private func addSendLabel(_ theme: TabBarModalViewTheme) {
        sendLabel.customizeAppearance(theme.sendLabel)

        addSubview(sendLabel)
        sendLabel.snp.makeConstraints {
            $0.top == sendButton.snp.bottom + theme.labelTopPadding
            $0.centerX == sendButton.snp.centerX
        }
    }

    private func addReceiveButton(_ theme: TabBarModalViewTheme) {
        receiveButton.customizeAppearance(theme.receiveButton)

        addSubview(receiveButton)
        receiveButton.snp.makeConstraints {
            $0.leading == snp.centerX + theme.horizontalPadding
            $0.centerY == 0
        }
    }

    private func addReceiveLabel(_ theme: TabBarModalViewTheme) {
        receiveLabel.customizeAppearance(theme.receiveLabel)

        addSubview(receiveLabel)
        receiveLabel.snp.makeConstraints {
            $0.top == receiveButton.snp.bottom + theme.labelTopPadding
            $0.centerX == receiveButton.snp.centerX
        }
    }
}
