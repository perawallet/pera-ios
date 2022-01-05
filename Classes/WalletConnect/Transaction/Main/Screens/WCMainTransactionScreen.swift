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
//   WCMainTransactionScreen.swift

import Foundation
import MacaroonUIKit
import MacaroonBottomOverlay
import UIKit
import SnapKit

final class WCMainTransactionScreen:
    BaseViewController,
    Container,
    BottomScrollOverlayContainer,
    BottomDetailOverlayContainer
{
    override var shouldShowNavigationBar: Bool {
        return false
    }

    /// Common
    lazy var styleSheet = WCMainTransactionScreenStyleSheet()
    lazy var layoutSheet = WCMainTransactionScreenLayoutSheet()


    /// Scroll
    var scrollOverlayViewTopConstraint: Constraint!
    var lastScrollOverlayOffset: LayoutMetric = 0
    var lastScrollOverlayTranslationOnScroll: LayoutMetric = 0
    var runningScrollOverlayAnimator: UIViewPropertyAnimator?

    private(set) lazy var scrollOverlayView = BottomOverlayView(
        contentView: scrollFragmentScreen.view
    )
    private(set) lazy var scrollFragmentScreen = WCScrollOverlayFragment(configuration: configuration)

    private var lastScrollOverlayPositionBeforeDetail: BottomScrollOverlayPosition = .mid
    /// Detail
    var detailOverlayViewTopConstraint: Constraint!
    var initialDetailOverlayOffset: LayoutMetric = 0
    var runningDetailOverlayAnimator: UIViewPropertyAnimator?
    private(set) lazy var detailOverlayView = BottomOverlayView(
        contentView: detailFragmentScreen.view
    )

    private(set) lazy var detailFragmentScreen = WCDetailOverlayFragment(configuration: configuration)
    private var isDetailBeingShown = true
    private var isLayoutFinalized = false

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = UIColor.black
        customizeScrollOverlayAppearance()
        customizeDetailOverlayAppearance()
    }

    override func prepareLayout() {
        super.prepareLayout()

        self.addScrollOverlay()
        self.addDetailOverlay()
    }

    override func linkInteractors() {
        super.linkInteractors()

        scrollFragmentScreen.scrollView.panGestureRecognizer.addTarget(
            self,
            action: #selector(moveScrollOverlayOnPan(_:))
        )
        detailOverlayView.addGestureRecognizer(
            UIPanGestureRecognizer(
                target: self,
                action: #selector(moveDetailOverlayOnPan(_:))
            )
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty {
            return
        }

        if !isLayoutFinalized {
            updateLayoutWhenViewDidFirstLayoutSubviews()
            isLayoutFinalized = true
        }

        updateScrollFragmentLayoutWhenViewDidLayoutSubviews()
    }

    private func updateLayoutWhenViewDidFirstLayoutSubviews() {
        layoutSheet.calculateScrollOverlayOffsetsAtEachPosition(
            in: self
        )

        updateScrollOverlayLayoutWhenViewDidFirstLayoutSubviews()
        updateDetailOverlayLayoutWhenViewDidFirstLayoutSubviews()
    }
}

extension WCMainTransactionScreen {
    @objc
    private func moveScrollOverlayOnPan(
        _ sender: UIPanGestureRecognizer
    ) {
        moveScrollOverlay(
            by: sender
        )
    }

    @objc
    private func moveDetailOverlayOnPan(
        _ sender: UIPanGestureRecognizer
    ) {
        moveDetailOverlay(
            by: sender
        )
    }
}



extension WCMainTransactionScreen {
    func scrollOverlayWillMove(to position: BottomScrollOverlayPosition) {
        print("scrollOverlayWillMove")
//        updateLayoutWhenScrollOverlayWillMove(
//            to: position
//        )
    }

    func scrollOverlayDidMove(to position: BottomScrollOverlayPosition) {
        if isDetailBeingShown {
            return
        }

        lastScrollOverlayPositionBeforeDetail = position
    }
}

extension WCMainTransactionScreen {

    func detailOverlayViewWillBecomeVisible(_ isVisible: Bool) {
        print("detailOverlayViewWillBecomeVisible")
//        updateLayoutWhenDetailOverlayWillBecomeVisible(
//            isVisible
//        )

    }
    func detailOverlayViewDidBecomevisible(_ isVisible: Bool) {
        print("detailOverlayViewDidBecomevisible")
//        updateLayoutWhenDetailOverlayDidBecomeVisible(
//            isVisible
//        )
    }
}




