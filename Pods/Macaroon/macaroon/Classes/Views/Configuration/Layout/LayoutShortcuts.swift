// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

extension UIView {
    public func fitToHorizontalIntrinsicSize(
        hugging: UILayoutPriority = .required,
        compression: UILayoutPriority = .required
    ) {
        if hugging != .none() {
            setContentHuggingPriority(
                hugging,
                for: .horizontal
            )
        }

        if compression != .none() {
            setContentCompressionResistancePriority(
                compression,
                for: .horizontal
            )
        }
    }

    public func fitToVerticalIntrinsicSize(
        hugging: UILayoutPriority = .required,
        compression: UILayoutPriority = .required
    ) {
        if hugging != .none() {
            setContentHuggingPriority(
                hugging,
                for: .vertical
            )
        }

        if compression != .none() {
            setContentCompressionResistancePriority(
                compression,
                for: .vertical
            )
        }
    }
}

extension ConstraintMaker {
    public typealias SizeConstraints =
        (
            width: Constraint?,
            height: Constraint?
        )

    public typealias PaddingConstraints =
        (
            top: Constraint?,
            leading: Constraint?,
            bottom: Constraint?,
            trailing: Constraint?
        )

    public typealias HorizontalPaddingConstraints =
        (
            leading: Constraint?,
            trailing: Constraint?
        )

    public typealias VerticalPaddingConstraints =
        (
            top: Constraint?,
            bottom: Constraint?
        )

    public typealias CenterConstraints =
        (
            x: Constraint?,
            y: Constraint?
        )
}

/// <mark>
/// Size
extension ConstraintMaker {
    @discardableResult
    public func fitToSize(
        _ size: LayoutSize
    ) -> SizeConstraints {
        return fitToSize(
            (
                (size.w, .required),
                (size.h, .required)
            )
        )
    }

    @discardableResult
    public func fitToSize(
        _ size: PrioritizedLayoutSize
    ) -> SizeConstraints {
        let widthConstraint =
            fitToWidth(
                size.w
            )
        let heightConstraint =
            fitToHeight(
                size.h
            )

        return (widthConstraint, heightConstraint)
    }

    @discardableResult
    public func fitToWidth(
        _ w: LayoutMetric
    ) -> Constraint? {
        return fitToWidth(
            (w, .required)
        )
    }

    @discardableResult
    public func fitToWidth(
        _ w: PrioritizedLayoutMetric
    ) -> Constraint? {
        if w.metric.isNoMetric {
            return nil
        }

        return
            width
            .equalTo(w.metric)
            .priority(w.priority)
            .constraint
    }

    @discardableResult
    public func fitToHeight(
        _ h: LayoutMetric
    ) -> Constraint? {
        return fitToHeight(
            (h, .required)
        )
    }

    @discardableResult
    public func fitToHeight(
        _ h: PrioritizedLayoutMetric
    ) -> Constraint? {
        if h.metric.isNoMetric {
            return nil
        }

        return
            height
            .equalTo(h.metric)
            .priority(h.priority)
            .constraint
    }

    @discardableResult
    public func greaterThanSize(
        _ size: LayoutSize
    ) -> SizeConstraints {
        return greaterThanSize(
            (
                (size.w, .required),
                (size.h, .required)
            )
        )
    }

    @discardableResult
    public func greaterThanSize(
        _ size: PrioritizedLayoutSize
    ) -> SizeConstraints {
        let widthConstraint =
            greaterThanWidth(
                size.w
            )
        let heightConstraint =
            greaterThanHeight(
                size.h
            )

        return (widthConstraint, heightConstraint)
    }

    @discardableResult
    public func greaterThanWidth(
        _ w: LayoutMetric
    ) -> Constraint? {
        return greaterThanWidth(
            (w, .required)
        )
    }

    @discardableResult
    public func greaterThanWidth(
        _ w: PrioritizedLayoutMetric
    ) -> Constraint? {
        if w.metric.isNoMetric {
            return nil
        }

        return
            width
            .greaterThanOrEqualTo(w.metric)
            .priority(w.priority)
            .constraint
    }

    @discardableResult
    public func greaterThanHeight(
        _ h: LayoutMetric
    ) -> Constraint? {
        return greaterThanHeight(
            (h, .required)
        )
    }

    @discardableResult
    public func greaterThanHeight(
        _ h: PrioritizedLayoutMetric
    ) -> Constraint? {
        if h.metric.isNoMetric {
            return nil
        }

        return
            height
            .greaterThanOrEqualTo(h.metric)
            .priority(h.priority)
            .constraint
    }

    @discardableResult
    public func lessThanSize(
        _ size: LayoutSize
    ) -> SizeConstraints {
        return lessThanSize(
            (
                (size.w, .required),
                (size.h, .required)
            )
        )
    }

    @discardableResult
    public func lessThanSize(
        _ size: PrioritizedLayoutSize
    ) -> SizeConstraints {
        let widthConstraint =
            lessThanWidth(
                size.w
            )
        let heightConstraint =
            lessThanHeight(
                size.h
            )

        return (widthConstraint, heightConstraint)
    }

    @discardableResult
    public func lessThanWidth(
        _ w: LayoutMetric
    ) -> Constraint? {
        return lessThanWidth(
            (w, .required)
        )
    }

    @discardableResult
    public func lessThanWidth(
        _ w: PrioritizedLayoutMetric
    ) -> Constraint? {
        if w.metric.isNoMetric {
            return nil
        }

        return
            width
            .lessThanOrEqualTo(w.metric)
            .priority(w.priority)
            .constraint
    }

    @discardableResult
    public func lessThanHeight(
        _ h: LayoutMetric
    ) -> Constraint? {
        return lessThanHeight(
            (h, .required)
        )
    }

    @discardableResult
    public func lessThanHeight(
        _ h: PrioritizedLayoutMetric
    ) -> Constraint? {
        if h.metric.isNoMetric {
            return nil
        }

        return
            height
            .lessThanOrEqualTo(h.metric)
            .priority(h.priority)
            .constraint
    }

    @discardableResult
    public func scale(
        _ view: UIView,
        aspectRatio: LayoutMetric
    ) -> Constraint? {
        return scale(
            view,
            aspectRatio: (aspectRatio, .required)
        )
    }

    @discardableResult
    public func scale(
        _ view: UIView,
        aspectRatio: PrioritizedLayoutMetric
    ) -> Constraint? {
        if aspectRatio.metric.isNoMetric {
            return nil
        }

        return
            width
            .equalTo(view.snp.height)
            .multipliedBy(aspectRatio.metric)
            .priority(aspectRatio.priority)
            .constraint
    }

    @discardableResult
    public func scale(
        _ view: UIView,
        reversedAspectRatio: LayoutMetric
    ) -> Constraint? {
        return scale(
            view,
            reversedAspectRatio: (reversedAspectRatio, .required)
        )
    }

    @discardableResult
    public func scale(
        _ view: UIView,
        reversedAspectRatio: PrioritizedLayoutMetric
    ) -> Constraint? {
        if reversedAspectRatio.metric.isNoMetric {
            return nil
        }

        return
            height
            .equalTo(view.snp.width)
            .multipliedBy(reversedAspectRatio.metric)
            .priority(reversedAspectRatio.priority)
            .constraint
    }

    @discardableResult
    public func matchToSize(
        of view: UIView,
        offset: LayoutSize
    ) -> SizeConstraints {
        let widthConstraint =
            matchToWidth(
                of: view,
                offset: offset.w
            )
        let heightConstraint =
            matchToHeight(
                of: view,
                offset: offset.h
            )

        return (widthConstraint, heightConstraint)
    }

    @discardableResult
    public func matchToWidth(
        of view: UIView,
        offset: LayoutMetric
    ) -> Constraint? {
        return
            width
            .equalTo(view.snp.width)
            .offset(offset)
            .constraint
    }

    @discardableResult
    public func matchToHeight(
        of view: UIView,
        offset: LayoutMetric
    ) -> Constraint? {
        return
            height
            .equalTo(view.snp.height)
            .offset(offset)
            .constraint
    }

    @discardableResult
    public func matchToSize(
        of view: UIView,
        multiplier: LayoutSize = (1, 1)
    ) -> SizeConstraints {
        let widthConstraint =
            matchToWidth(
                of: view,
                multiplier: multiplier.w
            )
        let heightConstraint =
            matchToHeight(
                of: view,
                multiplier: multiplier.h
            )

        return (widthConstraint, heightConstraint)
    }

    @discardableResult
    public func matchToWidth(
        of view: UIView,
        multiplier: LayoutMetric = 1
    ) -> Constraint? {
        return
            width
            .equalTo(view.snp.width)
            .multipliedBy(multiplier)
            .constraint
    }

    @discardableResult
    public func matchToHeight(
        of view: UIView,
        multiplier: LayoutMetric = 1
    ) -> Constraint? {
        return
            height
            .equalTo(view.snp.height)
            .multipliedBy(multiplier)
            .constraint
    }
}

/// <mark>
/// Paddings
extension ConstraintMaker {
    @discardableResult
    public func setPaddings(
        _ paddings: LayoutPaddings = (0, 0, 0, 0)
    ) -> PaddingConstraints {
        return setPaddings(
            (
                (paddings.top, .required),
                (paddings.leading, .required),
                (paddings.bottom, .required),
                (paddings.trailing, .required)
            )
        )
    }

    @discardableResult
    public func setPaddings(
        _ paddings: PrioritizedLayoutPaddings
    ) -> PaddingConstraints {
        let horizontalConstraints =
            setHorizontalPaddings(
                (paddings.leading, paddings.trailing)
            )
        let verticalConstraints =
            setVerticalPaddings(
                (paddings.top, paddings.bottom)
            )

        return (
            verticalConstraints.top,
            horizontalConstraints.leading,
            verticalConstraints.bottom,
            horizontalConstraints.trailing
        )
    }

    @discardableResult
    public func greaterThanPaddings(
        _ paddings: LayoutPaddings = (0, 0, 0, 0)
    ) -> PaddingConstraints {
        return greaterThanPaddings(
            (
                (paddings.top, .required),
                (paddings.leading, .required),
                (paddings.bottom, .required),
                (paddings.trailing, .required)
            )
        )
    }

    @discardableResult
    public func greaterThanPaddings(
        _ paddings: PrioritizedLayoutPaddings
    ) -> PaddingConstraints {
        let horizontalConstraints =
            greaterThanHorizontalPaddings(
                (paddings.leading, paddings.trailing)
            )
        let verticalConstraints =
            greaterThanVerticalPaddings(
                (paddings.top, paddings.bottom)
            )

        return (
            verticalConstraints.top,
            horizontalConstraints.leading,
            verticalConstraints.bottom,
            horizontalConstraints.trailing
        )
    }

    @discardableResult
    public func lessThanPaddings(
        _ paddings: LayoutPaddings = (0, 0, 0, 0)
    ) -> PaddingConstraints {
        return lessThanPaddings(
            (
                (paddings.top, .required),
                (paddings.leading, .required),
                (paddings.bottom, .required),
                (paddings.trailing, .required)
            )
        )
    }

    @discardableResult
    public func lessThanPaddings(
        _ paddings: PrioritizedLayoutPaddings
    ) -> PaddingConstraints {
        let horizontalConstraints =
            lessThanHorizontalPaddings(
                (paddings.leading, paddings.trailing)
            )
        let verticalConstraints =
            lessThanVerticalPaddings(
                (paddings.top, paddings.bottom)
            )

        return (
            verticalConstraints.top,
            horizontalConstraints.leading,
            verticalConstraints.bottom,
            horizontalConstraints.trailing
        )
    }

    @discardableResult
    public func setHorizontalPaddings(
        _ paddings: LayoutHorizontalPaddings = (0, 0)
    ) -> HorizontalPaddingConstraints {
        return setHorizontalPaddings(
            (
                (paddings.leading, .required),
                (paddings.trailing, .required)
            )
        )
    }

    @discardableResult
    public func setHorizontalPaddings(
        _ paddings: PrioritizedLayoutHorizontalPaddings
    ) -> HorizontalPaddingConstraints {
        var leadingConstraint: Constraint?
        var trailingConstraint: Constraint?

        if !paddings.leading.metric.isNoMetric {
            leadingConstraint =
                leading
                .equalToSuperview()
                .inset(
                    paddings.leading.metric
                )
                .priority(paddings.leading.priority)
                .constraint
        }

        if !paddings.trailing.metric.isNoMetric {
            trailingConstraint =
                trailing
                .equalToSuperview()
                .inset(
                    paddings.trailing.metric
                )
                .priority(paddings.trailing.priority)
                .constraint
        }

        return (leadingConstraint, trailingConstraint)
    }

    @discardableResult
    public func setHorizontalPaddings(
        _ paddings: LayoutHorizontalPaddings,
        inSafeAreaOf view: UIView
    ) -> HorizontalPaddingConstraints {
        return setHorizontalPaddings(
            (
                (paddings.leading, .required),
                (paddings.trailing, .required)
            )
            ,
            inSafeAreaOf: view
        )
    }

    @discardableResult
    public func setHorizontalPaddings(
        _ paddings: PrioritizedLayoutHorizontalPaddings,
        inSafeAreaOf view: UIView
    ) -> HorizontalPaddingConstraints {
        var leadingConstraint: Constraint?
        var trailingConstraint: Constraint?

        if !paddings.leading.metric.isNoMetric {
            leadingConstraint =
                leading
                .equalTo(view.safeAreaLayoutGuide.snp.leading)
                .inset(
                    paddings.leading.metric
                )
                .priority(paddings.leading.priority)
                .constraint
        }

        if !paddings.trailing.metric.isNoMetric {
            trailingConstraint =
                trailing
                .equalTo(view.safeAreaLayoutGuide.snp.trailing)
                .inset(
                    paddings.trailing.metric
                )
                .priority(paddings.trailing.priority)
                .constraint
        }

        return (leadingConstraint, trailingConstraint)
    }

    @discardableResult
    public func greaterThanHorizontalPaddings(
        _ paddings: LayoutHorizontalPaddings
    ) -> HorizontalPaddingConstraints {
        return greaterThanHorizontalPaddings(
            (
                (paddings.leading, .required),
                (paddings.trailing, .required)
            )
        )
    }

    @discardableResult
    public func greaterThanHorizontalPaddings(
        _ paddings: PrioritizedLayoutHorizontalPaddings
    ) -> HorizontalPaddingConstraints {
        var leadingConstraint: Constraint?
        var trailingConstraint: Constraint?

        if !paddings.leading.metric.isNoMetric {
            leadingConstraint =
                leading
                .lessThanOrEqualToSuperview()
                .inset(
                    paddings.leading.metric
                )
                .priority(paddings.leading.priority)
                .constraint
        }

        if !paddings.trailing.metric.isNoMetric {
            trailingConstraint =
                trailing
                .greaterThanOrEqualToSuperview()
                .inset(
                    paddings.trailing.metric
                )
                .priority(paddings.trailing.priority)
                .constraint
        }

        return (leadingConstraint, trailingConstraint)
    }

    @discardableResult
    public func lessThanHorizontalPaddings(
        _ paddings: LayoutHorizontalPaddings
    ) -> HorizontalPaddingConstraints {
        return lessThanHorizontalPaddings(
            (
                (paddings.leading, .required),
                (paddings.trailing, .required)
            )
        )
    }

    @discardableResult
    public func lessThanHorizontalPaddings(
        _ paddings: PrioritizedLayoutHorizontalPaddings
    ) -> HorizontalPaddingConstraints {
        var leadingConstraint: Constraint?
        var trailingConstraint: Constraint?

        if !paddings.leading.metric.isNoMetric {
            leadingConstraint =
                leading
                .greaterThanOrEqualToSuperview()
                .inset(
                    paddings.leading.metric
                )
                .priority(paddings.leading.priority)
                .constraint
        }

        if !paddings.trailing.metric.isNoMetric {
            trailingConstraint =
                trailing
                .lessThanOrEqualToSuperview()
                .inset(
                    paddings.trailing.metric
                )
                .priority(paddings.trailing.priority)
                .constraint
        }

        return (leadingConstraint, trailingConstraint)
    }

    @discardableResult
    public func setVerticalPaddings(
        _ paddings: LayoutVerticalPaddings = (0, 0)
    ) -> VerticalPaddingConstraints {
        return setVerticalPaddings(
            (
                (paddings.top, .required),
                (paddings.bottom, .required)
            )
        )
    }

    @discardableResult
    public func setVerticalPaddings(
        _ paddings: PrioritizedLayoutVerticalPaddings
    ) -> VerticalPaddingConstraints {
        var topConstraint: Constraint?
        var bottomConstraint: Constraint?

        if !paddings.top.metric.isNoMetric {
            topConstraint =
                top
                .equalToSuperview()
                .inset(
                    paddings.top.metric
                )
                .priority(paddings.top.priority)
                .constraint
        }

        if !paddings.bottom.metric.isNoMetric {
            bottomConstraint =
                bottom
                .equalToSuperview()
                .inset(
                    paddings.bottom.metric
                )
                .priority(paddings.bottom.priority)
                .constraint
        }

        return (topConstraint, bottomConstraint)
    }

    @discardableResult
    public func setTopPadding(
        _ padding: LayoutMetric,
        inSafeAreaOf view: UIView
    ) -> Constraint {
        return setTopPadding(
            (padding, .required),
            inSafeAreaOf: view
        )
    }

    @discardableResult
    public func setTopPadding(
        _ padding: PrioritizedLayoutMetric,
        inSafeAreaOf view: UIView
    ) -> Constraint {
        return top
            .equalTo(view.safeAreaLayoutGuide.snp.top)
            .inset(
                padding.metric
            )
            .priority(padding.priority)
            .constraint
    }

    @discardableResult
    public func setBottomPadding(
        _ padding: LayoutMetric,
        inSafeAreaOf view: UIView
    ) -> Constraint {
        return setBottomPadding(
            (padding, .required),
            inSafeAreaOf: view
        )
    }

    @discardableResult
    public func setBottomPadding(
        _ padding: PrioritizedLayoutMetric,
        inSafeAreaOf view: UIView
    ) -> Constraint {
        return bottom
            .equalTo(view.safeAreaLayoutGuide.snp.bottom)
            .inset(
                padding.metric
            )
            .priority(padding.priority)
            .constraint
    }

    @discardableResult
    public func greaterThanVerticalPaddings(
        _ paddings: LayoutVerticalPaddings
    ) -> VerticalPaddingConstraints {
        return greaterThanVerticalPaddings(
            (
                (paddings.top, .required),
                (paddings.bottom, .required)
            )
        )
    }

    @discardableResult
    public func greaterThanVerticalPaddings(
        _ paddings: PrioritizedLayoutVerticalPaddings
    ) -> VerticalPaddingConstraints {
        var topConstraint: Constraint?
        var bottomConstraint: Constraint?

        if !paddings.top.metric.isNoMetric {
            topConstraint =
                top
                .lessThanOrEqualToSuperview()
                .inset(
                    paddings.top.metric
                )
                .priority(paddings.top.priority)
                .constraint
        }

        if !paddings.bottom.metric.isNoMetric {
            bottomConstraint =
                bottom
                .greaterThanOrEqualToSuperview()
                .inset(
                    paddings.bottom.metric
                )
                .priority(paddings.bottom.priority)
                .constraint
        }

        return (topConstraint, bottomConstraint)
    }

    @discardableResult
    public func lessThanVerticalPaddings(
        _ paddings: LayoutVerticalPaddings
    ) -> VerticalPaddingConstraints {
        return lessThanVerticalPaddings(
            (
                (paddings.top, .required),
                (paddings.bottom, .required)
            )
        )
    }

    @discardableResult
    public func lessThanVerticalPaddings(
        _ paddings: PrioritizedLayoutVerticalPaddings
    ) -> VerticalPaddingConstraints {
        var topConstraint: Constraint?
        var bottomConstraint: Constraint?

        if !paddings.top.metric.isNoMetric {
            topConstraint =
                top
                .greaterThanOrEqualToSuperview()
                .inset(
                    paddings.top.metric
                )
                .priority(paddings.top.priority)
                .constraint
        }

        if !paddings.bottom.metric.isNoMetric {
            bottomConstraint =
                bottom
                .lessThanOrEqualToSuperview()
                .inset(
                    paddings.bottom.metric
                )
                .priority(paddings.bottom.priority)
                .constraint
        }

        return (topConstraint, bottomConstraint)
    }
}

/// <mark>
/// Center
extension ConstraintMaker {
    @discardableResult
    public func center(
        offset: LayoutOffset = (0, 0)
    ) -> CenterConstraints {
        return center(
            offset: (
                (offset.x, .required),
                (offset.y, .required)
            )
        )
    }

    @discardableResult
    public func center(
        offset: PrioritizedLayoutOffset
    ) -> CenterConstraints {
        var xConstraint: Constraint?
        var yConstraint: Constraint?

        if !offset.x.metric.isNoMetric {
            xConstraint =
                centerX
                .equalToSuperview()
                .offset(offset.x.metric)
                .priority(offset.x.priority)
                .constraint
        }

        if !offset.y.metric.isNoMetric {
            yConstraint =
                centerY
                .equalToSuperview()
                .offset(offset.y.metric)
                .priority(offset.y.priority)
                .constraint
        }

        return (xConstraint, yConstraint)
    }

    @discardableResult
    public func centerHorizontally(
        offset: LayoutMetric = 0,
        verticalPaddings: LayoutVerticalPaddings = (.noMetric, .noMetric)
    ) -> (offset: Constraint, verticalPaddings: VerticalPaddingConstraints) {
        return centerHorizontally(
            offset: (offset, .required),
            verticalPaddings: (
                (verticalPaddings.top, .required),
                (verticalPaddings.bottom, .required)
            )
        )
    }

    @discardableResult
    public func centerHorizontally(
        offset: PrioritizedLayoutMetric,
        verticalPaddings: PrioritizedLayoutVerticalPaddings
    ) -> (offset: Constraint, verticalPaddings: VerticalPaddingConstraints) {
        if offset.metric.isNoMetric {
            mc_crash(
                .layoutConstraintCorrupted(reason: "This method expect an offset")
            )
        }

        let offsetConstraint =
            centerX
            .equalToSuperview()
            .offset(offset.metric)
            .priority(offset.priority)
            .constraint

        var topConstraint: Constraint?
        var bottomConstraint: Constraint?

        if !verticalPaddings.top.metric.isNoMetric {
            topConstraint =
                top
                .equalToSuperview()
                .inset(verticalPaddings.top.metric)
                .priority(verticalPaddings.top.priority)
                .constraint
        }

        if !verticalPaddings.bottom.metric.isNoMetric {
            bottomConstraint =
                bottom
                .equalToSuperview()
                .inset(verticalPaddings.bottom.metric)
                .priority(verticalPaddings.bottom.priority)
                .constraint
        }

        return (offsetConstraint, (topConstraint, bottomConstraint))
    }

    @discardableResult
    public func centerVertically(
        offset: LayoutMetric = 0,
        horizontalPaddings: LayoutHorizontalPaddings = (.noMetric, .noMetric)
    ) -> (offset: Constraint, horizontalPaddings: HorizontalPaddingConstraints) {
        return centerVertically(
            offset: (offset, .required),
            horizontalPaddings: (
                (horizontalPaddings.leading, .required),
                (horizontalPaddings.trailing, .required)
            )
        )
    }

    @discardableResult
    public func centerVertically(
        offset: PrioritizedLayoutMetric,
        horizontalPaddings: PrioritizedLayoutHorizontalPaddings
    ) -> (offset: Constraint, horizontalPaddings: HorizontalPaddingConstraints) {
        if offset.metric.isNoMetric {
            mc_crash(
                .layoutConstraintCorrupted(reason: "This method expect an offset")
            )
        }

        let offsetConstraint =
            centerY
            .equalToSuperview()
            .offset(offset.metric)
            .priority(offset.priority)
            .constraint

        var leadingConstraint: Constraint?
        var trailingConstraint: Constraint?

        if !horizontalPaddings.leading.metric.isNoMetric {
            leadingConstraint =
                leading
                .equalToSuperview()
                .inset(horizontalPaddings.leading.metric)
                .priority(horizontalPaddings.leading.priority)
                .constraint
        }

        if !horizontalPaddings.trailing.metric.isNoMetric {
            trailingConstraint =
                trailing
                .equalToSuperview()
                .inset(horizontalPaddings.trailing.metric)
                .priority(horizontalPaddings.trailing.priority)
                .constraint
        }

        return (offsetConstraint, (leadingConstraint, trailingConstraint))
    }

    @discardableResult
    public func center(
        offset: LayoutOffset = (0, 0),
        of anotherView: UIView
    ) -> CenterConstraints {
        return center(
            offset: (
                (offset.x, .required),
                (offset.y, .required)
            ),
            of: anotherView
        )
    }

    @discardableResult
    public func center(
        offset: PrioritizedLayoutOffset,
        of anotherView: UIView
    ) -> CenterConstraints {
        var xConstraint: Constraint?
        var yConstraint: Constraint?

        if !offset.x.metric.isNoMetric {
            xConstraint =
                centerX
                .equalTo(anotherView)
                .offset(offset.x.metric)
                .priority(offset.x.priority)
                .constraint
        }

        if !offset.y.metric.isNoMetric {
            xConstraint =
                centerY
                .equalTo(anotherView)
                .offset(offset.y.metric)
                .priority(offset.y.priority)
                .constraint
        }

        return (xConstraint, yConstraint)
    }
}

extension Array where Element == Constraint {
    public func activate() {
        forEach { $0.activate() }
    }

    public func deactivate() {
        forEach { $0.deactivate() }
    }
}
