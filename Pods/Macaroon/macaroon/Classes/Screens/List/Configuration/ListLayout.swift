// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol ListLayout: AnyObject {
    static var flowLayoutClass: AnyClass { get }

    var listView: UICollectionView! { get set }
    var scrollDirection: UICollectionView.ScrollDirection { get }
    var itemSize: ListItemSize { get }
    var headerSize: ListSupplementarySize { get }
    var footerSize: ListSupplementarySize { get }
    var minimumLineSpacing: ListSpacing { get }
    var minimumInteritemSpacing: ListSpacing { get }
    var contentInset: LayoutPaddings { get }
    var sectionInset: ListSectionInset { get }
    var headersPinToVisibleBounds: Bool { get }
    var footersPinToVisibleBounds: Bool { get }

    func prepareForUse()
    func dequeueCell(for item: Any?, at indexPath: IndexPath) -> UICollectionViewCell
    func configure(_ cell: UICollectionViewCell, with item: Any?, at indexPath: IndexPath)
    func dequeueHeader(for item: Any?, in section: Int) -> UICollectionReusableView
    func configure(header: UICollectionReusableView, with item: Any?, in section: Int)
    func shouldShowHeadersForEmptySection(_ section: Int) -> Bool
    func dequeueFooter(for item: Any?, in section: Int) -> UICollectionReusableView
    func configure(footer: UICollectionReusableView, with item: Any?, in section: Int)
    func shouldShowFooterForEmptySection(_ section: Int) -> Bool
}

extension ListLayout {
    public static var flowLayoutClass: AnyClass {
        return UICollectionViewFlowLayout.self
    }

    public var scrollDirection: UICollectionView.ScrollDirection {
        return .vertical
    }
    public var headerSize: ListSupplementarySize {
        return .fixed(.zero)
    }
    public var footerSize: ListSupplementarySize {
        return .fixed(.zero)
    }
    public var minimumLineSpacing: ListSpacing {
        return .fixed(0)
    }
    public var minimumInteritemSpacing: ListSpacing {
        return .fixed(0)
    }
    public var contentInset: LayoutPaddings {
        return (.noMetric, .noMetric, .noMetric, .noMetric)
    }
    public var sectionInset: ListSectionInset {
        return .fixed(.zero)
    }
    public var headersPinToVisibleBounds: Bool {
        return true
    }
    public var footersPinToVisibleBounds: Bool {
        return true
    }

    // swiftlint:disable unavailable_function
    public func dequeueHeader(for item: Any?, in section: Int) -> UICollectionReusableView {
        mc_crash(.unsupportedListHeader(UICollectionReusableView.self))
    }
    // swiftlint:enable unavailable_function

    public func configure(header: UICollectionReusableView, with item: Any?, in section: Int) { }

    public func shouldShowHeadersForEmptySection(_ section: Int) -> Bool {
        return false
    }

    // swiftlint:disable unavailable_function
    public func dequeueFooter(for item: Any?, in section: Int) -> UICollectionReusableView {
        mc_crash(.unsupportedListFooter(UICollectionReusableView.self))
    }
    // swiftlint:enable unavailable_function

    public func configure(footer: UICollectionReusableView, with item: Any?, in section: Int) { }

    public func shouldShowFooterForEmptySection(_ section: Int) -> Bool {
        return false
    }
}

extension ListLayout {
    public var contentWidth: CGFloat {
        return listView.bounds.width - listView.adjustedContentInset.x
    }

    public var contentHeight: CGFloat {
        return listView.bounds.height - listView.adjustedContentInset.y
    }

    public var contentElementFittingSize: CGSize {
        return CGSize(width: contentWidth, height: .greatestFiniteMagnitude)
    }
}

extension ListLayout {
    public func cell(for item: Any?, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueCell(for: item, at: indexPath)
        configure(cell, with: item, at: indexPath)
        return cell
    }

    public func header(for item: Any?, in section: Int) -> UICollectionReusableView {
        let header = dequeueHeader(for: item, in: section)
        configure(header: header, with: item, in: section)
        return header
    }

    public func footer(for item: Any?, in section: Int) -> UICollectionReusableView {
        let footer = dequeueFooter(for: item, in: section)
        configure(footer: footer, with: item, in: section)
        return footer
    }

    public func size(for item: Any?, at indexPath: IndexPath) -> CGSize {
        switch itemSize {
        case .fixed(let fixedSize):
            return fixedSize
        case .dynamic(let calculator):
            return calculator(item, indexPath)
        case .selfSizing:
            return CGSize(width: -1.0, height: -1.0)
        }
    }

    public func headerSize(for item: Any?, in section: Int) -> CGSize {
        switch headerSize {
        case .fixed(let fixedHeaderSize):
            return fixedHeaderSize
        case .dynamic(let calculator):
            return calculator(item, section)
        }
    }

    public func footerSize(for item: Any?, in section: Int) -> CGSize {
        switch footerSize {
        case .fixed(let fixedFooterSize):
            return fixedFooterSize
        case .dynamic(let calculator):
            return calculator(item, section)
        }
    }

    public func minimumLineSpacing(for item: Any?, in section: Int) -> CGFloat {
        switch minimumLineSpacing {
        case .fixed(let fixedMinimumLineSpacing):
            return fixedMinimumLineSpacing
        case .dynamic(let calculator):
            return calculator(item, section)
        }
    }

    public func minimumInteritemSpacing(for item: Any?, in section: Int) -> CGFloat {
        switch minimumInteritemSpacing {
        case .fixed(let fixedMinimumInteritemSpacing):
            return fixedMinimumInteritemSpacing
        case .dynamic(let calculator):
            return calculator(item, section)
        }
    }

    public func sectionInset(for item: Any?, in section: Int) -> UIEdgeInsets {
        switch sectionInset {
        case .fixed(let fixedSectionInset):
            return fixedSectionInset
        case .dynamic(let calculator):
            return calculator(item, section)
        }
    }
}

extension ListLayout {
    public func visibleHeader(in section: Int) -> UICollectionReusableView? {
        return listView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section))
    }

    public func visibleFooter(in section: Int) -> UICollectionReusableView? {
        return listView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: section))
    }
}

extension ListLayout {
    public func reloadHeader(with item: Any?, in section: Int, forceInvalidation: Bool = false, animated: Bool = false) {
        if let visibleHeader = listView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section)) {
            configure(header: visibleHeader, with: item, in: section)

            if forceInvalidation {
                invalidateHeader(in: section, animated: animated)
            }
        } else {
            invalidateHeader(in: section, animated: animated)
        }
    }
}

extension ListLayout {
    public func invalidateLayout(forceLayoutUpdate: Bool = false) {
        collectionViewLayout.invalidateLayout()

        if forceLayoutUpdate {
            listView.layoutIfNeeded()
        }
    }

    public func invalidateItems(at indexPaths: [IndexPath], animated: Bool = false) {
        let context = UICollectionViewFlowLayoutInvalidationContext()
        context.invalidateFlowLayoutDelegateMetrics = true
        context.invalidateItems(at: indexPaths)
        invalidateLayout(context, animated: animated)
    }

    public func invalidateHeader(in section: Int, animated: Bool = false) {
        let context = UICollectionViewFlowLayoutInvalidationContext()
        context.invalidateFlowLayoutDelegateMetrics = true
        context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader, at: [IndexPath(item: 0, section: section)])
        invalidateLayout(context, animated: animated)
    }

    public func invalidateLayout(_ context: UICollectionViewFlowLayoutInvalidationContext, animated: Bool = false) {
        let applyUpdates: () -> Void = {
            self.listView.performBatchUpdates({ self.collectionViewLayout.invalidateLayout(with: context) })
        }
        if animated {
            let animator = UIViewPropertyAnimator(duration: 0.33, dampingRatio: 0.5, animations: applyUpdates)
            animator.startAnimation()
        } else {
            UIView.performWithoutAnimation(applyUpdates)
        }
    }
}

extension ListLayout {
    var collectionViewLayout: UICollectionViewFlowLayout {
        if listView == nil {
            return formFlowLayout()
        }
        guard let flowLayout = listView.collectionViewLayout as? UICollectionViewFlowLayout else {
            mc_crash(.unsupportedListLayout)
        }
        return flowLayout
    }

    private func formFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = (Self.flowLayoutClass as? UICollectionViewFlowLayout.Type)?.init() ?? UICollectionViewFlowLayout()
        flowLayout.scrollDirection = scrollDirection
        flowLayout.sectionHeadersPinToVisibleBounds = headersPinToVisibleBounds
        flowLayout.sectionFootersPinToVisibleBounds = footersPinToVisibleBounds
        setItemSize(flowLayout)
        setMinimumLineSpacingIfNeeded(flowLayout)
        setMinimumInteritemSpacingIfNeeded(flowLayout)
        setSectionInsetIfNeeded(flowLayout)
        return flowLayout
    }

    private func setItemSize(_ flowLayout: UICollectionViewFlowLayout) {
        switch itemSize {
        case .fixed(let fixedItemSize):
            flowLayout.estimatedItemSize = .zero
            flowLayout.itemSize = fixedItemSize
        case .dynamic:
            flowLayout.estimatedItemSize = .zero
        case .selfSizing:
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }

    private func setMinimumLineSpacingIfNeeded(_ flowLayout: UICollectionViewFlowLayout) {
        switch minimumLineSpacing {
        case .fixed(let fixedMinimumLineSpacing):
            flowLayout.minimumLineSpacing = fixedMinimumLineSpacing
        case .dynamic:
            break
        }
    }

    private func setMinimumInteritemSpacingIfNeeded(_ flowLayout: UICollectionViewFlowLayout) {
        switch minimumInteritemSpacing {
        case .fixed(let fixedMinimumInteritemSpacing):
            flowLayout.minimumInteritemSpacing = fixedMinimumInteritemSpacing
        case .dynamic:
            break
        }
    }

    private func setSectionInsetIfNeeded(_ flowLayout: UICollectionViewFlowLayout) {
        switch sectionInset {
        case .fixed(let fixedSectionInset):
            flowLayout.sectionInset = fixedSectionInset
        case .dynamic:
            break
        }
    }
}

public enum ListItemSize {
    public typealias SizeCalculator = (Any?, IndexPath) -> CGSize

    case fixed(CGSize)
    case dynamic(SizeCalculator)
    case selfSizing /// <warning> Not implemented. It can cause some issues.
}

public enum ListSupplementarySize {
    public typealias SizeCalculator = (Any?, Int) -> CGSize

    case fixed(CGSize)
    case dynamic(SizeCalculator)
}

public enum ListSpacing {
    public typealias SpacingCalculator = (Any?, Int) -> CGFloat

    case fixed(CGFloat)
    case dynamic(SpacingCalculator)
}

public enum ListSectionInset {
    public typealias InsetCalculator = (Any?, Int) -> UIEdgeInsets

    case fixed(UIEdgeInsets)
    case dynamic(InsetCalculator)
}

extension UICollectionView {
    public convenience init(listLayout: ListLayout) {
        self.init(frame: .zero, collectionViewLayout: listLayout.collectionViewLayout)
        listLayout.listView = self
    }
}
