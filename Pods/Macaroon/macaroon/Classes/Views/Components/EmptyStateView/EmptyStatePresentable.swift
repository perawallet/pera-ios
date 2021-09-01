// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

public protocol EmptyStatePresentable: EmptyStateViewDataSource {
    var emptyState: EmptyStateView.State { get set }
    var emptyStateView: EmptyStateView { get }
}

extension EmptyStatePresentable {
    public var emptyStateDataSource: EmptyStateViewDataSource? {
        get { emptyStateView.dataSource }
        set { emptyStateView.dataSource = newValue }
    }
}

extension EmptyStatePresentable where Self: UIView {
    public var emptyState: EmptyStateView.State {
        get { emptyStateView.state }
        set {
            switch newValue {
            case .none:
                removeEmptyState()
            default:
                addEmptyState()
            }
            emptyStateView.state = newValue
        }
    }

    private func addEmptyState() {
        if emptyStateView.isDescendant(of: self) {
            return
        }

        addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.leading.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.trailing.equalToSuperview()
        }
    }

    private func removeEmptyState() {
        emptyStateView.removeFromSuperview()
    }
}

extension EmptyStatePresentable where Self: UICollectionView {
    public var emptyState: EmptyStateView.State {
        get { emptyStateView.state }
        set { emptyStateView.state = newValue }
    }
}

extension EmptyStatePresentable where Self: UIViewController {
    public var emptyState: EmptyStateView.State {
        get { emptyStateView.state }
        set {
            switch newValue {
            case .none:
                removeEmptyState()
            default:
                addEmptyState()
            }
            emptyStateView.state = newValue
        }
    }

    public func addEmptyState() {
        if emptyStateView.isDescendant(of: self.view) {
            return
        }

        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { maker in
            maker.top.equalToSuperview()
            maker.leading.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.trailing.equalToSuperview()
        }
    }

    public func removeEmptyState() {
        emptyStateView.removeFromSuperview()
    }
}
