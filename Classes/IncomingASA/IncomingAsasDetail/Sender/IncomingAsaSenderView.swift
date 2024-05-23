// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   IncomingAsaSenderView.swift

import Foundation
import UIKit
import MacaroonUIKit

// TODO:  IncomingAsaRequesSenderTheme
final class IncomingAsaSenderView:
    View,
    ViewModelBindable,
    ListReusable {
    
    
    private lazy var senderView = UILabel()
    private lazy var amountView = UILabel()
    
    func customize(_ theme: IncomingAsaSenderViewTheme) {
        addContent(theme)
    }

    static func calculatePreferredSize(
        _ viewModel: IncomingAsaSenderViewModel?,
        for theme: IncomingAsaSenderViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let maxContextSize = CGSize((width, .greatestFiniteMagnitude))

        let preferredHeight = viewModel.sender?.boundingSize(
            multiline: false,
            fittingSize: maxContextSize
        ).height
        return CGSize((width, min(preferredHeight?.ceil() ?? 0, size.height)))
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) { }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) { }

    func bindData(_ viewModel: IncomingAsaSenderViewModel?) {
        
        if let sender = viewModel?.sender {
            sender.load(in: senderView)
        } else {
            senderView.clearText()
        }
        
        if let amount = viewModel?.amount {
            amount.load(in: amountView)
        } else {
            amountView.clearText()
        }
    }

    func prepareForReuse() {
        senderView.clearText()
        amountView.clearText()
    }
}

extension IncomingAsaSenderView {
    func addContent(_ theme: IncomingAsaSenderViewTheme) {
        
        addSubview(senderView)
        senderView.snp.makeConstraints {
            $0.leading == 0
            $0.top == 0
            $0.width.equalTo(72)
            $0.bottom.equalToSuperview().inset(8)
        }
        senderView.customizeAppearance(theme.sender)
        
        addSubview(amountView)
        amountView.snp.makeConstraints {
            $0.trailing == 0
            $0.top == 0
            $0.centerY.equalTo(senderView)
        }
        amountView.customizeAppearance(theme.amount)
    }
}
