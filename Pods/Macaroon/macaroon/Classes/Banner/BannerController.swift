// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class BannerController {
    public private(set) lazy var contentView = VStackView()

    @Atomic(identifier: "uiExecuterQueue")
    public private(set) var uiExecuterQueue: [DispatchWorkItem] = []

    public private(set) var runningUiExecution: DispatchWorkItem?

    public var presentingBanners: [UIView] {
        return contentView.arrangedSubviews
    }

    public unowned let presentingView: UIView

    public var configuration: BannerControllerConfiguration

    private var contentShowConstraints: [Constraint] = []
    private var contentHideConstraints: [Constraint] = []

    private var isActive = false

    public init(
        presentingView: UIView,
        configuration: BannerControllerConfiguration = BannerControllerConfiguration()
    ) {
        self.presentingView = presentingView
        self.configuration = configuration
    }

    open func activate() {
        if isActive {
            return
        }

        addContent()
        hideContent(
            animated: false
        )

        isActive = true
    }

    open func deactivate() {
        if !isActive {
            return
        }

        dismissAll(
            animated: true
        ) { [weak self] in

            self?.removeContent()
            self?.isActive = false
        }
    }

    open func enqueue(
        _ bannerView: UIView
    ) {
        let presentingUiExecution =
            makePresentingUiExecution(
                for: bannerView
            )

        enqueueAndRunNextUiExecution(
            presentingUiExecution
        )
    }

    open func dequeueAll(
        animated: Bool = true
    ) {
        dismissAll(
            animated: animated,
            completion: nil
        )
    }
}

extension BannerController {
    private func addContent() {
        if contentView.isDescendant(
            of: presentingView
        ) {
            return
        }

        presentingView.addSubview(
            contentView
        )
        contentView.snp.makeConstraints {
            $0.setHorizontalPaddings(
                configuration.contentHorizontalPaddings
            )
        }
        contentView.spacing = configuration.contentStackSpacing

        contentShowConstraints =
            contentView.snp.prepareConstraints {
                $0.top == configuration.contentTopPadding
            }
        contentHideConstraints =
            contentView.snp.prepareConstraints {
                $0.bottom == presentingView.snp.top
            }
    }

    private func removeContent() {
        contentShowConstraints = []
        contentHideConstraints = []

        contentView.removeFromSuperview()
    }
}

extension BannerController {
    private func makePresentingUiExecution(
        for bannerView: UIView
    ) -> DispatchWorkItem {
        return makeUiExecution {
            strongSelf in

            strongSelf.present(
                bannerView
            ) { [weak self] in

                self?.finishPresenting(
                    for: bannerView
                )
            }
        }
    }

    private func present(
        _ bannerView: UIView,
        completion: @escaping () -> Void
    ) {
        presentingView.bringSubviewToFront(
            contentView
        )
        contentView.addArrangedSubview(
            bannerView
        )
        contentView.layoutIfNeeded()

        if presentingBanners.count > 1 {
            showBanner(
                bannerView,
                completion: completion
            )

            return
        }

        showContent(
            animated: true,
            completion: completion
        )
    }

    private func showBanner(
        _ bannerView: UIView,
        completion: @escaping () -> Void
    ) {
        bannerView.isHidden = true

        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                bannerView.isHidden = false
            },
            completion: {
                _ in

                completion()
            }
        )
    }

    private func finishPresenting(
        for bannerView: UIView
    ) {
        scheduleAutoDismissingUiExecution(
            for: bannerView
        )

        dequeueAndRunNextUiExecution()
    }

    private func scheduleAutoDismissingUiExecution(
        for bannerView: UIView
    ) {
        let enqueuDismissingUiExecution = makeUiExecution {
            strongSelf in

            if !strongSelf.presentingBanners.contains(
                where: {
                    $0 == bannerView
                }
            ) {
                return
            }

            let dismissingUiExecution =
                strongSelf.makeDismissingUiExecution(
                    for: bannerView
                )

            strongSelf.enqueueAndRunNextUiExecution(
                dismissingUiExecution
            )
        }

        asyncMainAfter(
            duration: configuration.minAutoDissmissDuration,
            workItem: enqueuDismissingUiExecution
        )
    }
}

extension BannerController {
    private func makeDismissingUiExecution(
        for bannerView: UIView
    ) -> DispatchWorkItem {
        return makeUiExecution {
            strongSelf in

            strongSelf.dismiss(
                bannerView
            ) { [weak self] in

                self?.finishDismissing(
                    for: bannerView
                )
            }
        }
    }

    private func dismiss(
        _ bannerView: UIView,
        completion: @escaping () -> Void
    ) {
        let dismissCompletion: () -> Void = {
            [weak self] in

            self?.contentView.deleteArrangedSubview(
                bannerView
            )
            completion()
        }

        if presentingBanners.count > 1 {
            hideDismissing(
                bannerView,
                completion: dismissCompletion
            )

            return
        }

        hideContent(
            animated: true,
            completion: dismissCompletion
        )
    }

    private func hideDismissing(
        _ bannerView: UIView,
        completion: @escaping () -> Void
    ) {
        if bannerView.isHidden {
            completion()
            return
        }

        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                bannerView.isHidden = true
            },
            completion: {
                _ in

                completion()
            }
        )
    }

    private func finishDismissing(
        for bannerView: UIView
    ) {
        dequeueAndRunNextUiExecution()
    }
}

extension BannerController {
    private func showContent(
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        contentHideConstraints.deactivate()
        contentShowConstraints.activate()

        if !animated {
            presentingView.layoutIfNeeded()
            return
        }

        animateContentLayout(
            completion: completion
        )
    }

    private func hideContent(
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        contentShowConstraints.deactivate()
        contentHideConstraints.activate()

        if !animated {
            presentingView.layoutIfNeeded()
            return
        }

        animateContentLayout(
            completion: completion
        )
    }

    private func animateContentLayout(
        completion: (() -> Void)?
    ) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                [unowned self] in

                self.presentingView.layoutIfNeeded()
            },
            completion: {
                _ in

                completion?()
            }
        )
    }
}

extension BannerController {
    private func dismissAll(
        animated: Bool,
        completion: (() -> Void)?
    ) {
        cancelPendingUiExecutions()

        let dismissingAllUiExecution = makeUiExecution {
            strongSelf in

            if strongSelf.presentingBanners.isEmpty {
                strongSelf.finishDismissingAll()
                return
            }

            strongSelf.hideContent(
                animated: true
            ) { [weak self] in

                guard let self = self else {
                    return
                }

                self.contentView.deleteAllArrangedSubviews()
                self.finishDismissingAll()
            }
        }

        enqueueAndRunNextUiExecution(
            dismissingAllUiExecution
        )
    }

    private func finishDismissingAll() {
        dequeueAndRunNextUiExecution()
    }
}

extension BannerController {
    private func enqueueAndRunNextUiExecution(
        _ uiExecution: DispatchWorkItem
    ) {
        $uiExecuterQueue.modify {
            $0.append(
                uiExecution
            )
        }

        runNextUiExecution()
    }

    private func dequeueAndRunNextUiExecution() {
        $uiExecuterQueue.modify {
            $0.remove {
                $0 === runningUiExecution
            }
            runningUiExecution = nil
        }

        runNextUiExecution()
    }

    private func runNextUiExecution() {
        if !isActive {
            return
        }

        if runningUiExecution != nil {
            return
        }

        runningUiExecution = uiExecuterQueue.first
        runningUiExecution?.perform()
    }

    private func cancelPendingUiExecutions() {
        $uiExecuterQueue.modify {
            let pendingUiExecutions =
                $0.removeAll {
                    $0 !== runningUiExecution
                }
            pendingUiExecutions.forEach {
                $0.cancel()
            }
        }
    }
}

extension BannerController {
    private func makeUiExecution(
        execute: @escaping (BannerController) -> Void
    ) -> DispatchWorkItem {
        return DispatchWorkItem(qos: .userInteractive) {
            [weak self] in

            guard let self = self else {
                return
            }

            execute(self)
        }
    }
}
