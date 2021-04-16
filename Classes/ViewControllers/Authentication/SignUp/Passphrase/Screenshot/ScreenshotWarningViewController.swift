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
//  ScreenshotWarningViewController.swift

import UIKit

class ScreenshotWarningViewController: BaseViewController {

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var screenshotWarningView = ScreenshotWarningView()

    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
    }

    override func setListeners() {
        screenshotWarningView.delegate = self
    }

    override func prepareLayout() {
        prepareWholeScreenLayoutFor(screenshotWarningView)
    }
}

extension ScreenshotWarningViewController: ScreenshotWarningViewDelegate {
    func screenshotWarningViewDidCloseScreen(_ screenshotWarningView: ScreenshotWarningView) {
        dismissScreen()
    }
}
