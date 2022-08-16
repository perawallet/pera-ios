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

//   ASADetailScreen.swift

import Foundation
import MacaroonUIKit
import SnapKit
import UIKit

final class ASADetailScreen:
    BaseViewController,
    Container {
    private lazy var previewView = ASADetailPreviewView()

    private lazy var moreDetailOverlayView = UIView()
    private lazy var moreDetailFragmentScreen = ASAMoreDetailScreen(configuration: configuration)

    private var lastScrollOverlayOffset: LayoutMetric = 0
    private var lastScrollOverlayTranslationOnScroll: LayoutMetric = 0
    private var isLayoutFinalized = false

    private var runningScrollOverlayAnimator: UIViewPropertyAnimator?

    private var currentScrollOverlayOffset: LayoutMetric {
        return moreDetailOverlayView.frame.minY
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.Defaults.background.uiColor

        view.addSubview(previewView)
        previewView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        previewView.startObserving(event: .layoutFinalized) {
            [unowned self] in

            if !self.isLayoutFinalized {
                return
            }

            self.updateFragmentOverlayWhenViewDidFirstLayoutSubviews()
            self.updateFragmentWhenViewDidLayoutSubviews()
        }

        moreDetailOverlayView.backgroundColor = .blue

        view.addSubview(moreDetailOverlayView)
        moreDetailOverlayView.snp.makeConstraints {
            $0.matchToHeight(of: view)
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        addFragment(moreDetailFragmentScreen) {
            fragmentView in

            moreDetailOverlayView.addSubview(fragmentView)
            fragmentView.snp.makeConstraints {
                $0.top == 0
                $0.leading == 0
                $0.bottom == 0
                $0.trailing == 0
            }
        }
        view.layoutIfNeeded()

        moreDetailFragmentScreen.setPagesScrollEnabled(false)
        moreDetailFragmentScreen.addTarget(
            self,
            action: #selector(moveScrollOverlay(by:))
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isLayoutFinalized {
            defer {
                isLayoutFinalized = true
            }

            moreDetailOverlayView.snp.updateConstraints {
                $0.top == previewView.frame.maxY
            }

            if !previewView.isLayoutFinalized {
                return
            }

            updateFragmentOverlayWhenViewDidFirstLayoutSubviews()
        }

        updateFragmentWhenViewDidLayoutSubviews()
    }
}

extension ASADetailScreen {
    private func updateFragmentOverlayWhenViewDidFirstLayoutSubviews() {
        moreDetailOverlayView.snp.updateConstraints {
            $0.matchToHeight(
                of: view,
                offset: -previewView.compressedHeight
            )
        }

        moveScrollOverlay(
            to: .expanded,
            withInitialVelocity: .zero,
            animated: false
        )
    }

    private func updateFragmentWhenViewDidLayoutSubviews() {
        if !previewView.isLayoutFinalized {
            return
        }

        let arePagesScrollEnabled = currentScrollOverlayOffset <= previewView.compressedHeight
        moreDetailFragmentScreen.setPagesScrollEnabled(arePagesScrollEnabled)
    }
}

extension ASADetailScreen {
    @objc
    private func moveScrollOverlay(
        by panGestureRecognizer: UIPanGestureRecognizer
    ) {
        let translation =
            panGestureRecognizer.translation(
                in: panGestureRecognizer.view
            ).y

        if !moreDetailFragmentScreen.activeScrollView.isScrollAtTop {
            lastScrollOverlayOffset = currentScrollOverlayOffset
            lastScrollOverlayTranslationOnScroll = translation

            return
        }

        switch panGestureRecognizer.state {
        case .began:
            scrollGestureDidBegin(
                panGestureRecognizer
            )
        case .changed:
            scrollGestureDidChange(
                panGestureRecognizer,
                byTranslation: translation
            )
        case .ended,
             .failed,
             .cancelled:
            scrollGestureDidComplete(
                panGestureRecognizer
            )
        default: break
        }
    }

    private func scrollGestureDidBegin(
        _ panGestureRecognizer: UIPanGestureRecognizer
    ) {
        discardRunningAnimationToMoveScrollOverlay()

        lastScrollOverlayOffset = currentScrollOverlayOffset
        lastScrollOverlayTranslationOnScroll = 0
    }

    private func scrollGestureDidChange(
        _ panGestureRecognizer: UIPanGestureRecognizer,
        byTranslation translation: CGFloat
    ) {
        let dTranslation = translation - lastScrollOverlayTranslationOnScroll
        let preferredScrollOverlayOffset = lastScrollOverlayOffset + dTranslation
        let newScrollOverlayOffset = max(previewView.compressedHeight, min(previewView.expandedHeight, preferredScrollOverlayOffset))

        moreDetailOverlayView.snp.updateConstraints {
            $0.top == newScrollOverlayOffset
        }

        lastScrollOverlayOffset = newScrollOverlayOffset
        lastScrollOverlayTranslationOnScroll = translation
    }

    private func scrollGestureDidComplete(
        _ panGestureRecognizer: UIPanGestureRecognizer
    ) {
        let newPosition = nearestScrollOverlayPosition(
            atOffset: currentScrollOverlayOffset,
            movingBy: panGestureRecognizer
        )
        let scrollOverlayOffsetAtPosition = newPosition == .expanded
            ? previewView.expandedHeight
            : previewView.compressedHeight
        let distanceY = scrollOverlayOffsetAtPosition - currentScrollOverlayOffset
        let velocity = panGestureRecognizer.initialVelocityForSpringAnimation(
            forDistance: CGPoint(x: 0, y: distanceY),
            in: panGestureRecognizer.view
        )

        moveScrollOverlay(
            to: newPosition,
            withInitialVelocity: velocity,
            animated: true
        )

        lastScrollOverlayOffset = currentScrollOverlayOffset
        lastScrollOverlayTranslationOnScroll = 0
    }

    private func nearestScrollOverlayPosition(
        atOffset offset: LayoutMetric,
        movingBy panGestureRecognizer: UIPanGestureRecognizer
    ) -> VisibleState {
        let projectedOffset =
            panGestureRecognizer.project(
                pointY: offset,
                decelerationRate: UIScrollView.DecelerationRate.fast.rawValue
            )
        let distanceToExpandedPosition = abs(previewView.expandedHeight - projectedOffset)
        let distanceToCompressedPosition = abs(previewView.compressedHeight - projectedOffset)

        let expectedState: VisibleState
        let expectedHeight: CGFloat

        if distanceToExpandedPosition < distanceToCompressedPosition {
            expectedState = .expanded
            expectedHeight = previewView.expandedHeight
        } else {
            expectedState = .compressed
            expectedHeight = previewView.compressedHeight
        }

        let velocity =
            panGestureRecognizer.velocity(
                in: panGestureRecognizer.view
            ).y

        if (expectedHeight - offset) * velocity >= 0 {
            return expectedState
        }

        /// <note>
        /// if velocity is too low to change the current anchor, select the next anchor anyway.
        return velocity < 0 ?  .expanded : .compressed
    }

    private func moveScrollOverlay(
        to state: VisibleState,
        withInitialVelocity velocity: CGVector,
        animated: Bool
    ) {
        let scrollOverlayOffsetAtPosition = state == .expanded
            ? previewView.expandedHeight
            : previewView.compressedHeight

        if scrollOverlayOffsetAtPosition == currentScrollOverlayOffset {
            return
        }

        discardRunningAnimationToMoveScrollOverlay()

        moreDetailOverlayView.snp.updateConstraints {
            $0.top == scrollOverlayOffsetAtPosition
        }

        if !animated {
            return
        }

        startAnimationToMoveScrollOverlay(
            withInitialVelocity: velocity
        ) { [weak self] isCompleted in

            guard let self = self else {
                return
            }

            if !isCompleted {
                return
            }
        }
    }

    private func startAnimationToMoveScrollOverlay(
        withInitialVelocity velocity: CGVector,
        completion: @escaping (Bool) -> Void
    ) {
        let springTimingParameters =
            UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: velocity)
        let animator =
            UIViewPropertyAnimator(duration: 0.5, timingParameters: springTimingParameters)
        animator.addAnimations {
            [unowned self] in

            self.view.layoutIfNeeded()
        }
        animator.isUserInteractionEnabled = true
        animator.isInterruptible = true
        animator.addCompletion {
            [weak self] state in

            guard let self = self else {
                return
            }

            self.runningScrollOverlayAnimator = nil

            completion(
                state == .end
            )
        }
        animator.startAnimation()

        runningScrollOverlayAnimator = animator
    }

    private func discardRunningAnimationToMoveScrollOverlay() {
        guard let animator = runningScrollOverlayAnimator else {
            return
        }

        animator.stopAnimation(
            false
        )
        animator.finishAnimation(
            at: .current
        )

        runningScrollOverlayAnimator = nil
    }
}

extension ASADetailScreen {
    enum VisibleState {
        case expanded
        case compressed
    }
}
