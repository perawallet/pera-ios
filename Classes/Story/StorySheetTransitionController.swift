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

//   StorySheetTransitionController.swift

import Foundation
import MacaroonUIKit
import MacaroonStorySheet
import UIKit

final class StorySheetTransitionController: MacaroonStorySheet.StorySheetTransitionController {
    init(presentingViewController: UIViewController, completion: @escaping () -> Void) {
        super.init(
            presentingViewController: presentingViewController,
            presentationConfiguration: StorySheetPresentationConfiguration(),
            completion: completion
        )

        presentationConfiguration.chromeStyle = [
            .backgroundColor(UIColor.black.withAlphaComponent(0.2))
        ]

        presentationConfiguration.overlayStyleSheet.backgroundSecondShadow = MacaroonUIKit.Shadow(
            color: UIColor.black,
            opacity: 0.24,
            offset: (0, 16),
            radius: 68,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (16, 16),
            corners: .allCorners
        )
        presentationConfiguration.overlayStyleSheet.backgroundShadow = MacaroonUIKit.Shadow(
            color: UIColor.black,
            opacity: 0.06,
            offset: (0, 0),
            radius: 1,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (16, 16),
            corners: .allCorners
        )
    }
}
