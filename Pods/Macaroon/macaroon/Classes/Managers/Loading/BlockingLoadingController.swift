// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class BlockingLoadingController {
    public private(set) var isLoading = false

    public private(set) var chromeView: UIView!
    public private(set) var loadingIndicator: LoadingIndicator!

    public unowned let presentingView: UIView

    public var configuration: BlockingLoadingControllerConfiguration

    private var loadingIndicatorStartConstraints: [Constraint] = []
    private var loadingIndicatorStopConstraints: [Constraint] = []

    public init(
        presentingView: UIView,
        configuration: BlockingLoadingControllerConfiguration =
            BlockingLoadingControllerConfiguration()
    ) {
        self.presentingView = presentingView
        self.configuration = configuration
    }

    open func startLoading() {
        if isLoading {
            return
        }

        isLoading = true

        prepareLayout()
        chromeView.layoutIfNeeded()

        animateLayoutWhenLoadingStatusDidChange(
            isLoading: true
        ) { [weak self] in

            guard let self = self else {
                return
            }

            self.loadingIndicator.startAnimating()
        }
    }

    open func stopLoading() {
        if !isLoading {
            return
        }

        self.loadingIndicator.stopAnimating()

        animateLayoutWhenLoadingStatusDidChange(
            isLoading: false
        ) { [weak self] in

            guard let self = self else {
                return
            }

            self.removeLayout()
            self.isLoading = false
        }
    }
}

extension BlockingLoadingController {
    private func animateLayoutWhenLoadingStatusDidChange(
        isLoading: Bool,
        completion: @escaping () -> Void
    ) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                [unowned self] in

                self.updateLayoutWhenLoadingStatusDidChange(
                    isLoading: isLoading
                )
                self.chromeView.layoutIfNeeded()
            },
            completion: {
                _ in

                completion()
            }
        )
    }
}

extension BlockingLoadingController {
    private func prepareLayout() {
        addChrome()
        addLoadingIndicator()

        updateLayoutWhenLoadingStatusDidChange(
            isLoading: false
        )
    }

    private func updateLayoutWhenLoadingStatusDidChange(
        isLoading: Bool
    ) {
        updateChromeLayoutWhenLoadingStatusDidChange(
            isLoading: isLoading
        )
        updateLoadingIndicatorLayoutWhenLoadingStatusDidChange(
            isLoading: isLoading
        )
    }

    private func removeLayout() {
        removeLoadingIndicator()
        removeChrome()
    }

    private func addChrome() {
        let view = UIView()
        view.customizeAppearance(
            configuration.chromeStyle
        )

        presentingView.addSubview(
            view
        )
        view.snp.makeConstraints {
            $0.setPaddings()
        }

        chromeView = view
    }

    private func updateChromeLayoutWhenLoadingStatusDidChange(
        isLoading: Bool
    ) {
        chromeView.alpha = isLoading ? 1 : 0
    }

    private func removeChrome() {
        chromeView.removeFromSuperview()
        chromeView = nil
    }

    private func addLoadingIndicator() {
        let view = configuration.loadingIndicatorClass.init()

        chromeView.addSubview(
            view
        )
        view.snp.makeConstraints {
            $0.width <= presentingView * configuration.loadingIndicatorMaxWidthRatio

            $0.centerHorizontally()
        }

        loadingIndicatorStartConstraints =
            view.snp.prepareConstraints {
                $0.centerVertically(
                    offset: configuration.loadingIndicatorCenterOffsetY
                )
            }
        loadingIndicatorStopConstraints =
            view.snp.prepareConstraints {
                $0.top == chromeView.snp.bottom
            }

        loadingIndicator = view
    }

    private func updateLoadingIndicatorLayoutWhenLoadingStatusDidChange(
        isLoading: Bool
    ) {
        if isLoading {
            loadingIndicatorStopConstraints.deactivate()
            loadingIndicatorStartConstraints.activate()
        } else {
            loadingIndicatorStartConstraints.deactivate()
            loadingIndicatorStopConstraints.activate()
        }
    }

    private func removeLoadingIndicator() {
        loadingIndicator.removeFromSuperview()
        loadingIndicator = nil
    }
}
