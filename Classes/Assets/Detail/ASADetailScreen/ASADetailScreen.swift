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
    private lazy var profileView = ASAProfileView()
    private lazy var quickActionsView = ASADetailQuickActionsView()

    private lazy var pagesFragmentScreen = PageContainer(configuration: configuration)
    private lazy var activityFragmentScreen = ASAActivitiesScreen(configuration: configuration)
    private lazy var aboutFragmentScreen = ASAAboutScreen(configuration: configuration)

    private lazy var currencyFormatter = CurrencyFormatter()

    private var lastDisplayState: DisplayState = .normal
    private var lastFramesOfFoldingAreaPerDisplayState: [DisplayState : CGRect] = [:]

    private var isDisplayStateInteractiveTransitionInProgress = false
    private var displayStateInteractiveTransitionInitialScrollDirection: ScrollVerticalDirection?
    private var displayStateInteractiveTransitionInitialFractionComplete: CGFloat = 0
    private var displayStateInteractiveTransitionAnimator: UIViewPropertyAnimator?

    private var pagesFragmentHeightConstraint: Constraint!
    private var pagesFragmentTopEdgeConstraint: Constraint!
    private var isViewLayoutLoaded = false

    private var isDisplayStateTransitionAnimationInProgress: Bool {
        return displayStateInteractiveTransitionAnimator?.state == .active
    }

    private let asset: Asset

    private let theme = ASADetailScreenTheme()

    init(
        asset: Asset,
        configuration: ViewControllerConfiguration
    ) {
        self.asset = asset
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
        setPagesVerticalScrollingEnabled(false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            updateUIWhenViewLayoutDidChangeIfNeeded()
            isViewLayoutLoaded = true
        }
    }
}

extension ASADetailScreen {
    private func addUI() {
        addBackground()
        addProfile()
        addQuickActions()

        addPagesFragment()
    }

    private func updateUIWhenViewLayoutDidChangeIfNeeded() {
        if isDisplayStateInteractiveTransitionInProgress { return }
        if isDisplayStateTransitionAnimationInProgress { return }
        if !isViewLayoutLoaded { return }
        if !profileView.isLayoutLoaded { return }
        if !quickActionsView.isLayoutLoaded { return }

        saveFramesOfFoldingAreaForPerDisplayState()
        updatePagesFragmentWhenViewLayoutDidChange()

        if pagesFragmentScreen.items.isEmpty {
            addPages()
        }
    }

    private func updateUI(for state: DisplayState) {
        updateProfile(for: state)
        updateQuickActions(for: state)
        updatePagesFragment(for: state)
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addProfile() {
        profileView.customize(theme.profile)

        view.addSubview(profileView)
        profileView.snp.makeConstraints {
            $0.top == theme.normalProfileVerticalEdgeInsets.top
            $0.leading == theme.profileHorizontalEdgeInsets.leading
            $0.trailing == theme.profileHorizontalEdgeInsets.trailing
        }

        profileView.startObserving(event: .layoutChanged) {
            [unowned self] in

            self.updateUIWhenViewLayoutDidChangeIfNeeded()
        }

        let viewModel = ASAProfileViewModel(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        profileView.bindData(viewModel)
    }

    private func updateProfile(for state: DisplayState) {
        switch state {
        case .normal:
            profileView.expand()
            profileView.snp.updateConstraints {
                $0.top == theme.normalProfileVerticalEdgeInsets.top
            }
        case .folded:
            profileView.compress()
            profileView.snp.updateConstraints {
                $0.top == theme.foldedProfileVerticalEdgeInsets.top
            }
        }
    }

    private func addQuickActions() {
        quickActionsView.customize(theme.quickActions)

        view.addSubview(quickActionsView)
        quickActionsView.snp.makeConstraints {
            $0.top == profileView.snp.bottom + theme.spacingBetweenProfileAndQuickActions
            $0.leading >= theme.profileHorizontalEdgeInsets.leading
            $0.trailing <= theme.profileHorizontalEdgeInsets.trailing
            $0.centerX == 0
        }

        quickActionsView.startObserving(event: .layoutChanged) {
            [unowned self] in

            self.updateUIWhenViewLayoutDidChangeIfNeeded()
        }

        let viewModel = ASADetailQuickActionsViewModel(asset: asset)
        quickActionsView.bindData(viewModel)
    }

    private func updateQuickActions(for state: DisplayState) {
        let isFolded = state == .folded
        quickActionsView.alpha = isFolded ? 0 : 1
    }

    private func addPagesFragment() {
        pagesFragmentScreen.view.customizeAppearance(theme.pagesFragmentBackground)

        addContent(pagesFragmentScreen) {
            fragmentView in

            view.addSubview(fragmentView)
            fragmentView.snp.makeConstraints {
                $0.leading == 0
                $0.trailing == 0

                pagesFragmentHeightConstraint = $0.matchToHeight(of: view)
                pagesFragmentTopEdgeConstraint = $0.top == 0
            }
        }
    }

    private func updatePagesFragmentWhenViewLayoutDidChange() {
        updatePagesFragment(for: lastDisplayState)
    }

    private func updatePagesFragment(for state: DisplayState) {
        let normalTopEdgeInset = getFrameOfFoldingArea(for: .folded).maxY
        pagesFragmentHeightConstraint.update(offset: -normalTopEdgeInset)

        updatePagesFragmentPosition(for: state)
    }

    private func updatePagesFragmentPosition(for state: DisplayState) {
        let topEdgeInset = getFrameOfFoldingArea(for: state).maxY
        pagesFragmentTopEdgeConstraint.update(inset: topEdgeInset)
    }

    private func updateFragmentWhenViewDidLayoutSubviews() {
//        if !profileView.isLayoutFinalized { return }
//
//        let arePagesScrollEnabled = calculateMoreDetailOverlayPosition() <= calculateHeaderHeight(for: .compressed)
//        setPagesVerticalScrollingEnabled(arePagesScrollEnabled)
    }

    private func addPages() {
        pagesFragmentScreen.items = [
            ActivityPageBarItem(screen: activityFragmentScreen),
            AboutPageBarItem(screen: aboutFragmentScreen)
        ]

        activityFragmentScreen.scrollView.panGestureRecognizer.addTarget(
            self,
            action: #selector(interactWithDisplayState(_:))
        )
        aboutFragmentScreen.scrollView.panGestureRecognizer.addTarget(
            self,
            action: #selector(interactWithDisplayState(_:))
        )
    }
}

extension ASADetailScreen {
    private func getFrameOfFoldingArea(for state: DisplayState) -> CGRect {
        let defaultFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 0)
        return lastFramesOfFoldingAreaPerDisplayState[state] ?? defaultFrame
    }

    private func saveFramesOfFoldingAreaForPerDisplayState() {
        for state in DisplayState.allCases {
            lastFramesOfFoldingAreaPerDisplayState[state] = calculateFrameOfFoldingArea(for: state)
        }
    }

    private func calculateFrameOfFoldingArea(for state: DisplayState) -> CGRect {
        let height: CGFloat
        switch state {
        case .normal:
            let topEdgeInset = theme.normalProfileVerticalEdgeInsets.top
            let profileHeight = profileView.intrinsicExpandedContentSize.height
            let quickActionsHeight = quickActionsView.bounds.height
            let bottomEdgeInset = theme.normalProfileVerticalEdgeInsets.bottom
            height =
                topEdgeInset +
                profileHeight +
                theme.spacingBetweenProfileAndQuickActions +
                quickActionsHeight +
                bottomEdgeInset
        case .folded:
            let topEdgeInset = theme.foldedProfileVerticalEdgeInsets.top
            let profileHeight = profileView.intrinsicCompressedContentSize.height
            let bottomEdgeInset = theme.foldedProfileVerticalEdgeInsets.bottom
            height =
                topEdgeInset +
                profileHeight +
                bottomEdgeInset
        }

        let origin = CGPoint.zero
        let width = view.bounds.width
        let size = CGSize(width: width, height: height)
        return CGRect(origin: origin, size: size)
    }
}

extension ASADetailScreen {
    private func setPagesVerticalScrollingEnabled(_ enabled: Bool) {
        activityFragmentScreen.isScrollEnabled = enabled
        aboutFragmentScreen.isScrollEnabled = enabled
    }
}

extension ASADetailScreen {
    @objc
    private func interactWithDisplayState(_ recognizer: UIPanGestureRecognizer) {
//        if !moreDetailFragmentScreen.activeScrollView.isScrollAtTop {
//            return
//        }

        switch recognizer.state {
        case .began:
            prepareForDisplayStateInteractiveTransition()
        case .changed:
            if isDisplayStateTransitionAnimationInProgress {
                updateDisplayStateInteractiveTransition(recognizer)
            } else {
                startDisplayStateInteractiveTransition(recognizer)
            }
        case .ended:
            completeDisplayStateInteractiveTransition(recognizer)
        case .failed:
            reverseDisplayStateInteractiveTransition(recognizer)
        case .cancelled:
            reverseDisplayStateInteractiveTransition(recognizer)
        default:
            break
        }
    }

    private func prepareForDisplayStateInteractiveTransition() {
        isDisplayStateInteractiveTransitionInProgress = true

        let fractionComplete = displayStateInteractiveTransitionAnimator?.fractionComplete ?? 0
        displayStateInteractiveTransitionInitialFractionComplete = fractionComplete
    }

    private func startDisplayStateInteractiveTransition(_ recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: recognizer.view)
        let direction = ScrollVerticalDirection(velocity: velocity)
        displayStateInteractiveTransitionInitialScrollDirection = direction

        let nextDisplayState = determineNextDisplayState(in: direction)
        displayStateInteractiveTransitionAnimator = startDisplayStateTransitionAnimation(
            to: nextDisplayState
        )
        displayStateInteractiveTransitionAnimator?.pauseAnimation()

        let fractionComplete = displayStateInteractiveTransitionAnimator?.fractionComplete ?? 0
        displayStateInteractiveTransitionInitialFractionComplete = fractionComplete
    }

    private func updateDisplayStateInteractiveTransition(_ recognizer: UIPanGestureRecognizer) {
        guard
            let animator = displayStateInteractiveTransitionAnimator,
            let scrollDirection = displayStateInteractiveTransitionInitialScrollDirection
        else { return }

        let translation = recognizer.translation(in: view)
        let normalPosition = getFrameOfFoldingArea(for: .normal).maxY
        let foldedPosition = getFrameOfFoldingArea(for: .folded).maxY
        let distance = normalPosition - foldedPosition

        var fraction: CGFloat
        switch scrollDirection {
        case .undetermined: fraction = 0
        case .up: fraction = max(0, translation.y / distance)
        case .down: fraction = max(0, -translation.y / distance)
        }

        if animator.isReversed {
            fraction *= -1
        }

        var fractionComplete: CGFloat = 0
        fractionComplete += displayStateInteractiveTransitionInitialFractionComplete
        fractionComplete += fraction

        animator.pauseAnimation()
        animator.fractionComplete = fractionComplete
    }

    private func completeDisplayStateInteractiveTransition(_ recognizer: UIPanGestureRecognizer) {
        guard let animator = displayStateInteractiveTransitionAnimator else { return }

        let scrollDirection = displayStateInteractiveTransitionInitialScrollDirection ?? .undetermined
        let velocity = recognizer.velocity(in: recognizer.view)

        if scrollDirection == .undetermined || velocity.y == 0 {
            animator.startAnimation()
            return
        }

        let isReversed = isDisplayStateInteractiveTransitionReversed(recognizer)
        if isReversed == animator.isReversed {
            animator.startAnimation()
        } else {
            reverseDisplayStateInteractiveTransition(recognizer)
        }
    }

    private func reverseDisplayStateInteractiveTransition(_ recognizer: UIPanGestureRecognizer) {
        guard let animator = displayStateInteractiveTransitionAnimator else { return }

        animator.isReversed.toggle()
        animator.continueAnimation(
            withTimingParameters: nil,
            durationFactor: 0
        )
    }

    private func isDisplayStateInteractiveTransitionReversed(_ recognizer: UIPanGestureRecognizer) -> Bool {
        let velocity = recognizer.velocity(in: recognizer.view)

        switch displayStateInteractiveTransitionInitialScrollDirection {
        case .none: return false
        case .undetermined: return false
        case .up: return velocity.y < 0
        case .down: return velocity.y > 0
        }
    }
}

extension ASADetailScreen {
    private func determineNextDisplayState(in scrollDirection: ScrollVerticalDirection) -> DisplayState {
        switch scrollDirection {
        case .undetermined: return lastDisplayState.reversed()
        case .up: return .normal
        case .down: return .folded
        }
    }
}

extension ASADetailScreen {
    private func startDisplayStateTransitionAnimation(to state: DisplayState) -> UIViewPropertyAnimator {
        let animator = makeTransitionAnimator(for: state)
        animator.startAnimation()
        return animator
    }

    private func makeTransitionAnimator(for state: DisplayState) -> UIViewPropertyAnimator {
        switch state {
        case .normal: return makeTransitionAnimatorForNormalDisplayState()
        case .folded: return makeTransitionAnimatorForFoldedDisplayState()
        }
    }

    private func makeTransitionAnimatorForNormalDisplayState() -> UIViewPropertyAnimator {
        let animator = makeTransitionAnimatorForAnyDisplayState()
        animator.addAnimations {
            [unowned self] in

            let state = DisplayState.normal

            self.updateProfile(for: state)
            self.updatePagesFragment(for: state)

            UIView.animateKeyframes(
                withDuration: 0,
                delay: 0
            ) {
                UIView.addKeyframe(
                    withRelativeStartTime: 0.75,
                    relativeDuration: 0.25
                ) { [unowned self] in
                    self.updateQuickActions(for: state)
                }
            }

            self.view.layoutIfNeeded()
        }
        return animator
    }

    private func makeTransitionAnimatorForFoldedDisplayState() -> UIViewPropertyAnimator {
        let animator = makeTransitionAnimatorForAnyDisplayState()
        animator.addAnimations {
            [unowned self] in

            let state = DisplayState.folded

            self.updateProfile(for: state)
            self.updatePagesFragment(for: state)

            UIView.animateKeyframes(
                withDuration: 0,
                delay: 0
            ) {
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.25
                ) { [unowned self] in
                    self.updateQuickActions(for: state)
                }
            }

            self.view.layoutIfNeeded()
        }
        return animator
    }

    private func makeTransitionAnimatorForAnyDisplayState() -> UIViewPropertyAnimator {
        let timingParameters = UISpringTimingParameters(
            mass: 1.8,
            stiffness: 707,
            damping: 56,
            initialVelocity: .zero
        )
        let animator = UIViewPropertyAnimator(duration: 0.386, timingParameters: timingParameters)
        animator.addCompletion {
            [weak self] position in
            guard let self = self else { return }

            if position == .end {
                self.lastDisplayState.reverse()
            }

            self.updateUI(for: self.lastDisplayState)
            self.view.setNeedsLayout()

            self.displayStateInteractiveTransitionInitialScrollDirection = nil
            self.displayStateInteractiveTransitionInitialFractionComplete = 0
            self.isDisplayStateInteractiveTransitionInProgress = false
        }
        return animator
    }
}

extension ASADetailScreen {
    private enum DisplayState: CaseIterable {
        case normal
        case folded

        mutating func reverse() {
            self = reversed()
        }

        func reversed() -> DisplayState {
            switch self {
            case .normal: return .folded
            case .folded: return .normal
            }
        }
    }
}
