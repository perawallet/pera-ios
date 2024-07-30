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

final class IncomingASARequesSenderView:
    View,
    ViewModelBindable,
    ListReusable {
    
    private lazy var senderView = UILabel()
    private lazy var amountView = UILabel()
    
    func customize(_ theme: IncomingASARequesSenderViewTheme) {
        addContent(theme)
    }

    static func calculatePreferredSize(
        _ viewModel: IncomingASARequesSenderViewModel?,
        for theme: IncomingASARequesSenderViewTheme,
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

    func bindData(_ viewModel: IncomingASARequesSenderViewModel?) {
        if let sender = viewModel?.sender?.string.shortAddressDisplayWith4Characters {
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

extension IncomingASARequesSenderView {
    func addContent(_ theme: IncomingASARequesSenderViewTheme) {
        
        addSubview(senderView)
        senderView.snp.makeConstraints {
            $0.leading == 0
            $0.top == 0
            $0.bottom.equalToSuperview().inset(theme.senderBottomInset)
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
