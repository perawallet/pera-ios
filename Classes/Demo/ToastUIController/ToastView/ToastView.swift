// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ToastView.swift

import Foundation
import MacaroonToastUIKit
import MacaroonUIKit
import UIKit

final class ToastView:
    View,
    ViewModelBindable {
    private lazy var messageView: UILabel = .init()

    private var messagePaddings: UIEdgeInsets?

    func customize(
        _ theme: ToastViewTheme
    ) {
        messagePaddings = theme.messagePaddings

        addBackground(theme)
        addMessage(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: ToastViewModel?
    ) {
        if let message = viewModel?.message {
            message.load(in: messageView)
        } else {
            messageView.mc_text = nil
            messageView.attributedText = nil
        }
    }

    override func sizeThatFits(
        _ size: CGSize
    ) -> CGSize {
        let someMessagePaddings = messagePaddings ?? .zero
        let messageMaxWidth = size.width - someMessagePaddings.horizontal
        let messageMaxHeight = size.height - someMessagePaddings.vertical
        let messageMaxSize = CGSize(width: messageMaxWidth, height: messageMaxHeight)
        let messageSize = messageView.sizeThatFits(messageMaxSize)
        let width = min(messageSize.width + someMessagePaddings.horizontal, size.width)
        let height = min(messageSize.height + someMessagePaddings.vertical, size.height)
        return CGSize(width: width, height: height)
    }
}

extension ToastView {
    private func addBackground(
        _ theme: ToastViewTheme
    ) {
        customizeAppearance(theme.background)
    }

    private func addMessage(
        _ theme: ToastViewTheme
    ) {
        messageView.customizeAppearance(theme.message)

        addSubview(messageView)
        messageView.fitToIntrinsicSize()
        messageView.snp.makeConstraints {
            $0.top == theme.messagePaddings.top
            $0.leading == theme.messagePaddings.left
            $0.bottom == theme.messagePaddings.bottom
            $0.trailing == theme.messagePaddings.right
        }
    }
}
