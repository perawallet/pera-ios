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
