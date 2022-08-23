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

//   ASADiscoveryScreen.swift

import Foundation
import MacaroonUIKit
import MagpieCore
import MagpieHipo
import SnapKit
import UIKit

final class ASADiscoveryScreen:
    BaseViewController,
    Container {
    private lazy var loadingView = makeLoading()
    private lazy var errorView = makeError()
    private lazy var profileView = ASAProfileView()

    private lazy var aboutFragmentScreen =
        ASAAboutScreen(
            asset: dataController.asset,
            copyToClipboardController: copyToClipboardController,
            configuration: configuration
        )

    private lazy var currencyFormatter = CurrencyFormatter()

    private var lastDisplayState = DisplayState.normal
    private var lastFrameOfFoldableArea = CGRect.zero

    private var isDisplayStateInteractiveTransitionInProgress = false
    private var displayStateInteractiveTransitionInitialFractionComplete: CGFloat = 0
    private var displayStateInteractiveTransitionScrollableAreaInitialContentOffsetY: CGFloat = 0
    private var displayStateInteractiveTransitionAnimator: UIViewPropertyAnimator?

    private var aboutFragmentHeightConstraint: Constraint!
    private var aboutFragmentTopEdgeConstraint: Constraint!
    private var isViewLayoutLoaded = false

    private var isDisplayStateTransitionAnimationInProgress: Bool {
        return displayStateInteractiveTransitionAnimator?.state == .active
    }

    private let dataController: ASADiscoveryScreenDataController
    private let copyToClipboardController: CopyToClipboardController

    private let theme = ASADiscoveryScreenTheme()

    init(
        dataController: ASADiscoveryScreenDataController,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addNavigationTitle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
        loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            updateUIWhenViewLayoutDidChangeIfNeeded()
            isViewLayoutLoaded = true
        }

        updateUIWhenViewDidLayoutSubviewsIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switchToHighlightedNavigationBarAppearance()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if presentedViewController == nil && isMovingFromParent {
            switchToDefaultNavigationBarAppearance()
        }
    }
}

extension ASADiscoveryScreen {
    private func addNavigationTitle() {
        let asset = dataController.asset
        navigationItem.title = asset.naming.unitName ?? asset.naming.name
    }

    private func addUI() {
        addBackground()
        addProfile()

        addAboutFragment()
    }

    private func updateUIWhenViewLayoutDidChangeIfNeeded() {
        if isDisplayStateInteractiveTransitionInProgress { return }
        if isDisplayStateTransitionAnimationInProgress { return }
        if !isViewLayoutLoaded { return }
        if !profileView.isLayoutLoaded { return }

        lastFrameOfFoldableArea = calculateFrameOfFoldableArea()

        updateAboutFragmentWhenViewLayoutDidChange()
    }

    private func updateUIWhenViewDidLayoutSubviewsIfNeeded() {
        if isDisplayStateInteractiveTransitionInProgress { return }
        if isDisplayStateTransitionAnimationInProgress { return }

        updateAboutFragmentWhenViewDidLayoutSubviews()
    }

    private func updateUI(for state: DisplayState) {
        updateProfile(for: state)
        updateAboutFragment(for: state)
    }

    private func updateUIWhenDataWillLoad() {
        addLoading()
        removeError()
    }

    private func updateUIWhenDataDidLoad() {
        bindUIData()
        removeLoading()
        removeError()
    }

    private func updateUIWhenDataDidFailToLoad(_ error: ASADiscoveryScreenDataController.Error) {
        addError()
        removeLoading()
    }

    private func bindUIData() {
        bindProfileData()
        bindAboutFragmentData()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func makeLoading() -> ASADiscoveryLoadingView {
        let loadingView = ASADiscoveryLoadingView()
        loadingView.customize(theme.loading)
        return loadingView
    }

    private func addLoading() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        loadingView.startAnimating()
    }

    private func removeLoading() {
        loadingView.removeFromSuperview()
        loadingView.stopAnimating()
    }

    private func makeError() -> NoContentWithActionView {
        let errorView = NoContentWithActionView()
        errorView.customizeAppearance(theme.errorBackground)
        errorView.customize(theme.error)
        return errorView
    }

    private func addError() {
        view.addSubview(errorView)
        errorView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        errorView.startObserving(event: .performPrimaryAction) {
            [weak self] in
            guard let self = self else { return }

            self.dataController.loadData()
        }

        /// <todo>
        /// Why don't we take as a reference the error for the view.
        errorView.bindData(ListErrorViewModel())
    }

    private func removeError() {
        errorView.removeFromSuperview()
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
        profileView.startObserving(event: .copyAssetID) {
            [unowned self] in

            let asset = dataController.asset
            self.copyToClipboardController.copyID(asset)
        }

        bindProfileData()
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

    private func bindProfileData() {
        let asset = dataController.asset
        let viewModel = ASADiscoveryProfileViewModel(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        profileView.bindData(viewModel)
    }

    private func addAboutFragment() {
        addContent(aboutFragmentScreen) {
            fragmentView in

            view.addSubview(fragmentView)
            fragmentView.snp.makeConstraints {
                $0.leading == 0
                $0.trailing == 0

                aboutFragmentHeightConstraint = $0.matchToHeight(of: view)
                aboutFragmentTopEdgeConstraint = $0.top == 0
            }
        }

        aboutFragmentScreen.scrollView.panGestureRecognizer.addTarget(
            self,
            action: #selector(updateUIWhenPagesScrollableAreaDidChange(_:))
        )
    }

    private func updateAboutFragmentWhenViewLayoutDidChange() {
        updateAboutFragment(for: lastDisplayState)
    }

    private func updateAboutFragment(for state: DisplayState) {
        let normalTopEdgeInset = calculateSpacingOverAboutFragment(for: .folded)
        aboutFragmentHeightConstraint.update(offset: -normalTopEdgeInset)

        updateAboutFragmentPosition(for: state)
    }

    private func updateAboutFragmentPosition(for state: DisplayState) {
        let topEdgeInset = calculateSpacingOverAboutFragment(for: state)
        aboutFragmentTopEdgeConstraint.update(inset: topEdgeInset)
    }

    private func updateAboutFragmentWhenPagesScrollableAreaDidChange() {
        updateAboutFragmentWhenViewDidLayoutSubviews()
    }

    private func updateAboutFragmentWhenViewDidLayoutSubviews() {
        /// <note>
        /// The area within the last point means the about fragment is folded. So, the about can be
        /// scrolled inside.
        var frameOfFoldingArea = lastFrameOfFoldableArea
        frameOfFoldingArea.origin.y += 1

        /// <note>
        /// If the about fragment is being animated, then `presentation()` gives us its actual frame
        /// which the animations are applied.
        let frameOfAboutFragment =
            aboutFragmentScreen.view.layer.presentation()?.frame ?? aboutFragmentScreen.view.frame
        let positionOfAboutFragment = frameOfAboutFragment.origin
        let isFolding = frameOfFoldingArea.contains(positionOfAboutFragment)

        aboutFragmentScreen.isScrollAnchoredOnTop = isFolding
    }

    private func bindAboutFragmentData() {
        let asset = dataController.asset
        aboutFragmentScreen.bindData(asset: asset)
    }
}

extension ASADiscoveryScreen {
    private func calculateSpacingOverAboutFragment(for state: DisplayState) -> CGFloat {
        switch state {
        case .normal: return lastFrameOfFoldableArea.maxY
        case .folded: return lastFrameOfFoldableArea.minY
        }
    }

    private func calculateFrameOfFoldableArea() -> CGRect {
        let width = view.bounds.width
        let minHeight =
            theme.foldedProfileVerticalEdgeInsets.top +
            profileView.intrinsicCompressedContentSize.height +
            theme.foldedProfileVerticalEdgeInsets.bottom
        let maxHeight =
            theme.normalProfileVerticalEdgeInsets.top +
            profileView.intrinsicExpandedContentSize.height +
            theme.normalProfileVerticalEdgeInsets.bottom
        let height = maxHeight - minHeight
        return CGRect(x: 0, y: minHeight, width: width, height: height)
    }
}

extension ASADiscoveryScreen {
    private func loadData() {
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .willLoadData: self.updateUIWhenDataWillLoad()
            case .didLoadData: self.updateUIWhenDataDidLoad()
            case .didFailToLoadData(let error): self.updateUIWhenDataDidFailToLoad(error)
            }
        }
        dataController.loadData()
    }
}

extension ASADiscoveryScreen {
    @objc
    private func updateUIWhenPagesScrollableAreaDidChange(_ recognizer: UIPanGestureRecognizer) {
        updateAboutFragmentWhenPagesScrollableAreaDidChange()

        switch recognizer.state {
        case .began: startDisplayStateInteractiveTransition(recognizer)
        case .changed: updateDisplayStateInteractiveTransition(recognizer)
        case .ended: completeDisplayStateInteractiveTransition(recognizer)
        case .failed: reverseDisplayStateInteractiveTransition(recognizer)
        case .cancelled: reverseDisplayStateInteractiveTransition(recognizer)
        default: break
        }
    }

    private func startDisplayStateInteractiveTransition(_ recognizer: UIPanGestureRecognizer) {
        isDisplayStateInteractiveTransitionInProgress = true

        if !isDisplayStateTransitionAnimationInProgress {
            let nextDisplayState = lastDisplayState.reversed()
            displayStateInteractiveTransitionAnimator =
                startDisplayStateTransitionAnimation(to: nextDisplayState)
        }

        displayStateInteractiveTransitionAnimator?.pauseAnimation()

        let fractionComplete = displayStateInteractiveTransitionAnimator?.fractionComplete ?? 0
        displayStateInteractiveTransitionInitialFractionComplete = fractionComplete

        let scrollView = aboutFragmentScreen.scrollView
        let contentOffsetY = scrollView.contentOffset.y
        let contentInsetTop = scrollView.adjustedContentInset.top
        displayStateInteractiveTransitionScrollableAreaInitialContentOffsetY = contentOffsetY + contentInsetTop
    }

    private func updateDisplayStateInteractiveTransition(_ recognizer: UIPanGestureRecognizer) {
        guard let animator = displayStateInteractiveTransitionAnimator else { return }

        animator.pauseAnimation()

        let translation = recognizer.translation(in: view)
        let normalSpacing = calculateSpacingOverAboutFragment(for: .normal)
        let foldedSpacing = calculateSpacingOverAboutFragment(for: .folded)
        let distance = normalSpacing - foldedSpacing
        let initialContentOffsetY = displayStateInteractiveTransitionScrollableAreaInitialContentOffsetY
        /// <note>
        /// In order to switch between the normal and folded states, the scroll should be on top for
        /// the about screen; therefore, the translation is projected on the content offset of the
        /// screen, and determine whether or not there is still space to be scrolled over before
        /// switching the next display state.
        let scrollFraction = (translation.y - initialContentOffsetY) / distance
        let nextDisplayState = lastDisplayState.reversed()
        let scrollDirectionMultiplier: CGFloat = nextDisplayState.isFolded ? -1 : 1
        let reverseMultiplier: CGFloat = animator.isReversed ? -1 : 1
        /// <note>
        /// While the translation is negative, the fraction should be positive on scrolling down.
        let fraction =
            scrollFraction *
            scrollDirectionMultiplier *
            reverseMultiplier

        var fractionComplete: CGFloat = 0
        fractionComplete += displayStateInteractiveTransitionInitialFractionComplete
        fractionComplete += fraction

        animator.fractionComplete = fractionComplete.clamped(0...1)
    }

    private func completeDisplayStateInteractiveTransition(_ recognizer: UIPanGestureRecognizer) {
        guard let animator = displayStateInteractiveTransitionAnimator else { return }

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
        guard let animator = displayStateInteractiveTransitionAnimator else {
            return false
        }

        let nextDisplayState = lastDisplayState.reversed()
        let contentOffsetYOnTop = -aboutFragmentScreen.scrollView.adjustedContentInset.top
        let contentOffsetY = aboutFragmentScreen.scrollView.contentOffset.y
        let velocityY = recognizer.velocity(in: recognizer.view).y

        /// <note>
        /// If there is still space to be scrolled over before switching the next display state,
        /// the animation should be reversed so that the pages fragment can't change its position.
        switch nextDisplayState {
        case .normal:
            if contentOffsetY > contentOffsetYOnTop {
                return true
            }

            if velocityY == 0 {
                return animator.isReversed
            }

            return velocityY < 0
        case .folded:
            if contentOffsetY < contentOffsetYOnTop {
                return true
            }

            if velocityY == 0 {
                return animator.isReversed
            }

            return velocityY > 0
        }
    }
}

extension ASADiscoveryScreen {
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
            self.updateUI(for: state)

            self.view.layoutIfNeeded()
        }
        return animator
    }

    private func makeTransitionAnimatorForFoldedDisplayState() -> UIViewPropertyAnimator {
        let animator = makeTransitionAnimatorForAnyDisplayState()
        animator.addAnimations {
            [unowned self] in

            let state = DisplayState.folded
            self.updateUI(for: state)

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

            self.displayStateInteractiveTransitionInitialFractionComplete = 0
            self.displayStateInteractiveTransitionScrollableAreaInitialContentOffsetY =
                self.aboutFragmentScreen.scrollView.contentOffset.y
            self.isDisplayStateInteractiveTransitionInProgress = false
        }
        return animator
    }
}

extension ASADiscoveryScreen {
    private enum DisplayState: CaseIterable {
        case normal
        case folded

        var isFolded: Bool {
            return self == .folded
        }

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
