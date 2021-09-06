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
//   BottomSheetTransitionController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class BottomSheetTransitionController: Macaroon.BottomSheetTransitionController {
    init(presentingViewController: UIViewController, completion: @escaping () -> Void) {
        super.init(
            presentingViewController: presentingViewController,
            presentationConfiguration:
                BottomSheetPresentationConfiguration(),
            completion: completion
        )

        presentationConfiguration.chromeStyle = [
            .backgroundColor(Colors.CardModal.background)
        ]

        presentationConfiguration.overlayOffset = 0
    }
}

extension Colors {
    fileprivate enum CardModal {
        static let background = color("bottomOverlayBackground")
    }
}
