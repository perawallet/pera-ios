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
//  PasswordInputCircle.swift

import UIKit
import Macaroon

final class PasswordInputCircleView: UIImageView, ViewComposable {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 20, height: 20)
    }
    
    var state: State = .empty {
        didSet {
            switch state {
            case .empty:
                image = img("gray-button-border")
            case .error:
                image = img("gray-button-border", isTemplate: true)
                tintColor = Colors.General.error
            case .filled:
                image = img("black-button-filled")
            }
        }
    }

    func customize() {
        image = img("gray-button-border")
        layer.cornerRadius = 10
        contentMode = .center
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension PasswordInputCircleView {
    enum State {
        case empty
        case filled
        case error
    }
}
