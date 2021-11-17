// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class ListView:
    UICollectionView,
    EmptyStatePresentable {
    public var invalidatesLayoutForReloadingItems = false

    public private(set) lazy var emptyStateView = EmptyStateView()

    public override init(
        frame: CGRect,
        collectionViewLayout layout: UICollectionViewLayout
    ) {
        super.init(
            frame: frame,
            collectionViewLayout: layout
        )

        customizeAppearance()
        prepareLayout()
    }

    @available(*, unavailable)
    public required init?(
        coder: NSCoder
    ) {
        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    open func customizeAppearance() {
        backgroundColor = .clear
    }

    open func prepareLayout() {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            switch flowLayout.scrollDirection {
            case .horizontal: alwaysBounceHorizontal = true
            case .vertical: alwaysBounceVertical = true
            @unknown default: break
            }
        }

        reorderingCadence = .fast
        backgroundView = emptyStateView
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        emptyStateView.frame = bounds
    }
}

extension ListView {
    public func reloadData(
        _ modifier: ListModifier,
        for listLayout: ListLayout,
        onAppeared isAppeared: Bool = false,
        onCompleted execute: (() -> Void)? = nil
    ) {
        switch modifier {
        case .none:
            execute?()
        case .reload:
            reloadData()
            execute?()
        case .update(let listSnapshot, let applyUpdates):
            if !listSnapshot.hasUpdates {
                execute?()
                return
            }

            if !isAppeared {
                applyUpdates?()
                reloadData()
                execute?()
                return
            }

            performBatchUpdates(
                listSnapshot,
                for: listLayout,
                onStarted: applyUpdates,
                onCompleted: execute
            )
        }
    }

    public func performBatchUpdates(
        _ listSnapshot: ListSnapshot,
        for listLayout: ListLayout,
        onStarted executeOnStarted: (() -> Void)?,
        onCompleted executeOnCompleted: (() -> Void)?
    ) {
        if !listSnapshot.hasUpdates {
            executeOnStarted?()
            executeOnCompleted?()

            return
        }

        let listUpdates = listSnapshot.updates

        for offset in listUpdates.reloads {
            let indexPath = IndexPath(item: offset, section: listUpdates.section)

            if let cell = cellForItem(
                at: indexPath
            ) {
                listLayout.configure(
                    cell,
                    with: listSnapshot[indexPath],
                    at: indexPath
                )
            }
        }

        for move in listUpdates.moves where move.isMutated {
            let srcIndexPath = IndexPath(item: move.source, section: listUpdates.section)
            let destIndexPath = IndexPath(item: move.destination, section: listUpdates.section)

            if let cell = cellForItem(
                at: srcIndexPath
            ) {
                listLayout.configure(
                    cell,
                    with: listSnapshot[destIndexPath],
                    at: srcIndexPath
                )
            }
        }

        performBatchUpdates(
            {
                executeOnStarted?()

                for offset in listUpdates.inserts {
                    let indexPath = IndexPath(item: offset, section: listUpdates.section)

                    insertItems(
                        at: [indexPath]
                    )
                }
                for offset in listUpdates.deletes {
                    let indexPath = IndexPath(item: offset, section: listUpdates.section)

                    deleteItems(
                        at: [indexPath]
                    )
                }
                for move in listUpdates.moves {
                    let srcIndexPath = IndexPath(item: move.source, section: listUpdates.section)
                    let destIndexPath = IndexPath(item: move.destination, section: listUpdates.section)

                    moveItem(
                        at: srcIndexPath,
                        to: destIndexPath
                    )
                }
            },
            completion: {
                [weak self] _ in

                guard let self = self else {
                    return
                }

                if self.invalidatesLayoutForReloadingItems {
                    let reloadingIndexPaths =
                        listUpdates.reloads.map {
                            IndexPath(item: $0, section: listUpdates.section)
                        }

                    listLayout.invalidateItems(
                        at: reloadingIndexPaths
                    )
                }

                executeOnCompleted?()
            }
        )
    }
}
