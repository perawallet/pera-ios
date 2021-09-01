// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

public class EmptyStateView: UIView {
    public weak var dataSource: EmptyStateViewDataSource?

    public var showsLoadingOnRefreshing = false

    public internal(set) var state: State = .none {
        didSet { stateDidChange() }
    }

    public private(set) var currentContentView: UIView?
}

extension EmptyStateView {
    private func stateDidChange() {
        updateContentWhenStateDidChange()
    }
}

extension EmptyStateView {
    private func updateContentWhenStateDidChange() {
        removeCurrentContent()

        switch state {
        case .none:
            break
        case .loading:
            addLoading()
        case .refreshing:
            if showsLoadingOnRefreshing {
                addLoading()
            }
        case .noContent(let userInfo):
            addNoContent(
                userInfo: userInfo
            )
        case .noNetwork(let userInfo):
            addNoNetwork(
                userInfo: userInfo
            )
        case .fault(let userInfo):
            addFault(
                userInfo: userInfo
            )
        }
    }

    public func removeCurrentContent() {
        if let loadingIndicator = currentContentView as? LoadingIndicator {
            loadingIndicator.stopAnimating()
        }

        currentContentView?.removeFromSuperview()
        currentContentView = nil
    }

    private func addLoading() {
        guard let dataSource = dataSource else {
            return
        }

        let someLoadingIndicator =
            dataSource.loadingIndicator(
                in: self
            )

        guard let loadingIndicator = someLoadingIndicator else {
            return
        }

        let contentAlignment =
            dataSource.contentAlignment(
                for: state,
                in: self
            )

        addSubview(
            loadingIndicator
        )
        loadingIndicator.fitToHorizontalIntrinsicSize()
        loadingIndicator.snp.makeConstraints {
            let horizontalPaddings: LayoutHorizontalPaddings

            switch contentAlignment {
            case .center(let offsetY, let someHorizontalPaddings):
                horizontalPaddings = someHorizontalPaddings

                $0.center(
                    offset: (0, offsetY)
                )
            case .scaleToFit(let paddings):
                horizontalPaddings = (paddings.leading, paddings.trailing)

                $0.centerHorizontally(
                    offset: 0,
                    verticalPaddings: (paddings.top, .noMetric)
                )
            }

            $0.width <=
                snp.width -
                horizontalPaddings.leading.layoutMetric -
                horizontalPaddings.trailing.layoutMetric
        }

        loadingIndicator.startAnimating()

        currentContentView = loadingIndicator
    }

    private func addNoContent(userInfo: Any?) {
        let someNoContentView =
            dataSource?.noContentView(
                userInfo: userInfo,
                in: self
            )

        guard let noContentView = someNoContentView else {
            return
        }

        addCustomContent(
            noContentView
        )
    }

    private func addNoNetwork(userInfo: Any?) {
        let someNoNetworkView =
            dataSource?.noNetworkView(
                userInfo: userInfo,
                in: self
            )

        guard let noNetworkView = someNoNetworkView else {
            return
        }

        addCustomContent(
            noNetworkView
        )
    }

    private func addFault(userInfo: Any?) {
        let someFaultView =
            dataSource?.faultView(
                userInfo: userInfo,
                in: self
            )

        guard let faultView = someFaultView else {
            return
        }

        addCustomContent(
            faultView
        )
    }

    private func addCustomContent(
        _ contentView: UIView
    ) {
        let contentAlignment =
            dataSource?.contentAlignment(
                for: state,
                in: self
            ) ?? .center(offset: 0, horizontalPaddings: (0, 0))

        addSubview(
            contentView
        )
        contentView.snp.makeConstraints {
            switch contentAlignment {
            case .center(let offsetY, let horizontalPaddings):
                $0.width <=
                    snp.width -
                    horizontalPaddings.leading.layoutMetric -
                    horizontalPaddings.trailing.layoutMetric
                $0.height <= snp.height
                $0.top >= 16

                $0.centerVertically(
                    offset: (offsetY, .defaultHigh),
                    horizontalPaddings: (
                        (horizontalPaddings.leading, .required),
                        (horizontalPaddings.trailing, .required)
                    )
                )
            case .scaleToFit(let paddings):
                $0.width <=
                    snp.width -
                    paddings.leading.layoutMetric -
                    paddings.trailing.layoutMetric
                $0.height <=
                    snp.height -
                    paddings.top.layoutMetric -
                    paddings.bottom.layoutMetric

                $0.setPaddings(
                    paddings
                )
            }
        }

        currentContentView = contentView
    }
}

extension EmptyStateView {
    public enum State {
        case none
        case loading
        case refreshing
        case noContent(userInfo: Any? = nil)
        case noNetwork(userInfo: Any? = nil)
        case fault(userInfo: Any? = nil)
    }

    public enum ContentAlignment {
        case center(offset: LayoutMetric, horizontalPaddings: LayoutHorizontalPaddings)
        case scaleToFit(LayoutPaddings)
    }
}

public protocol EmptyStateViewDataSource: AnyObject {
    func loadingIndicator(in view: EmptyStateView) -> LoadingIndicator?
    func noContentView(userInfo: Any?, in view: EmptyStateView) -> UIView?
    func noNetworkView(userInfo: Any?, in view: EmptyStateView) -> UIView?
    func faultView(userInfo: Any?, in view: EmptyStateView) -> UIView?
    /// <note>
    /// If the returning value isn't center, then the loading indicator will pin to top with the
    /// padding.
    func contentAlignment(for state: EmptyStateView.State, in view: EmptyStateView) -> EmptyStateView.ContentAlignment
}

extension EmptyStateViewDataSource {
    public func loadingIndicator(in view: EmptyStateView) -> LoadingIndicator? {
        if #available(iOS 13, *) {
            return UIActivityIndicatorView(style: .medium)
        }
        return UIActivityIndicatorView(style: .gray)
    }

    public func noContentView(userInfo: Any?, in view: EmptyStateView) -> UIView? {
        return nil
    }

    public func noNetworkView(userInfo: Any?, in view: EmptyStateView) -> UIView? {
        return nil
    }

    public func faultView(userInfo: Any?, in view: EmptyStateView) -> UIView? {
        return nil
    }

    public func contentAlignment(for state: EmptyStateView.State, in view: EmptyStateView) -> EmptyStateView.ContentAlignment {
        return .center(offset: 0, horizontalPaddings: (0, 0))
    }
}
