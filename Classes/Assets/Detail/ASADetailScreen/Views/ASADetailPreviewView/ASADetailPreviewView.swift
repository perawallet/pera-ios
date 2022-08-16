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

//   ASADetailPreviewView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ASADetailPreviewView:
    MacaroonUIKit.View,
    UIInteractable
{
    var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .layoutFinalized: UIBlockInteraction()
    ]

    private(set) var isLayoutFinalized = false
    private(set) var expandedHeight: CGFloat = 0
    private(set) var compressedHeight: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .red
        snp.makeConstraints {
            $0.fitToHeight(400)
        }

        let contentView = UIView()
        contentView.backgroundColor = UIColor.green
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.fitToHeight(400)
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    override func layoutSubviews() {
        super.layoutSubviews()

        if isLayoutFinalized {
            return
        }

        if bounds.isEmpty {
            return
        }

        expandedHeight = bounds.height
        compressedHeight = 60

        isLayoutFinalized = true

        let interaction = self.uiInteractions[.layoutFinalized] as? UIBlockInteraction
        interaction?.notify()
    }
}

extension ASADetailPreviewView {
    enum Event {
        case layoutFinalized
    }
}
