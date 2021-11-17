// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

/// <href>
/// https://www.swiftbysundell.com/articles/building-dsls-in-swift/
extension LayoutMetric {
    public static func ~ (
        lhs: LayoutMetric,
        rhs: UILayoutPriority
    ) -> PrioritizedLayoutMetric {
        return (lhs, rhs)
    }
}

extension LayoutConstraint {
    public static func + (
        lhs: LayoutConstraint,
        rhs: LayoutMetric
    ) -> LayoutConstraint {
        return LayoutConstraint(
            target: lhs.target,
            multiplier: lhs.multiplier,
            constant: lhs.constant.unwrap { $0 + rhs } ?? rhs,
            priority: lhs.priority
        )
    }

    public static func - (
        lhs: LayoutConstraint,
        rhs: LayoutMetric
    ) -> LayoutConstraint {
        return LayoutConstraint(
            target: lhs.target,
            multiplier: lhs.multiplier,
            constant: lhs.constant.unwrap { $0 - rhs } ?? -rhs,
            priority: lhs.priority
        )
    }

    public static func * (
        lhs: LayoutConstraint,
        rhs: LayoutMetric
    ) -> LayoutConstraint {
        return LayoutConstraint(
            target: lhs.target,
            multiplier: lhs.multiplier.unwrap { $0 * rhs } ?? rhs,
            constant: lhs.constant,
            priority: lhs.priority
        )
    }

    public static func ~ (
        lhs: LayoutConstraint,
        rhs: UILayoutPriority
    ) -> LayoutConstraint {
        if lhs.priority == nil {
            mc_crash(
                .layoutConstraintCorrupted(reason: "Priority must be set as the last parameter")
            )
        }

        return LayoutConstraint(
            target: lhs.target,
            multiplier: lhs.multiplier,
            constant: lhs.constant,
            priority: rhs
        )
    }
}

extension UIView {
    public static func + (
        lhs: UIView,
        rhs: LayoutMetric
    ) -> LayoutConstraint {
        return LayoutConstraint(view: lhs, constant: rhs)
    }

    public static func - (
        lhs: UIView,
        rhs: LayoutMetric
    ) -> LayoutConstraint {
        return LayoutConstraint(view: lhs, constant: -rhs)
    }

    public static func * (
        lhs: UIView,
        rhs: LayoutMetric
    ) -> LayoutConstraint {
        return LayoutConstraint(view: lhs, multiplier: rhs)
    }

    public static func ~ (
        lhs: UIView,
        rhs: UILayoutPriority
    ) -> LayoutConstraint {
        return LayoutConstraint(view: lhs, priority: rhs)
    }
}

extension ConstraintItem {
    public static func + (
        lhs: ConstraintItem,
        rhs: LayoutMetric
    ) -> LayoutConstraint {
        return LayoutConstraint(constraintItem: lhs, constant: rhs)
    }

    public static func - (
        lhs: ConstraintItem,
        rhs: LayoutMetric
    ) -> LayoutConstraint {
        return LayoutConstraint(constraintItem: lhs, constant: -rhs)
    }

    public static func * (
        lhs: ConstraintItem,
        rhs: LayoutMetric
    ) -> LayoutConstraint {
        return LayoutConstraint(constraintItem: lhs, multiplier: rhs)
    }

    public static func ~ (
        lhs: ConstraintItem,
        rhs: UILayoutPriority
    ) -> LayoutConstraint {
        return LayoutConstraint(constraintItem: lhs, priority: rhs)
    }
}

extension ConstraintMakerExtendable {
    @discardableResult
    public static func == (
        lhs: ConstraintMakerExtendable,
        rhs: LayoutConstraint
    ) -> Constraint {
        var maker: ConstraintMakerEditable

        switch rhs.target {
        case .superview:
            maker = lhs.equalToSuperview()
        case .constraintItem(let constraintItem):
            maker =
                lhs.equalTo(
                    constraintItem
                )
        case .view(let view):
            maker =
                lhs.equalTo(
                    view
                )
        }

        return makeConstraint(
            maker,
            of: rhs
        )
    }

    @discardableResult
    public static func == (
        lhs: ConstraintMakerExtendable,
        rhs: LayoutMetric
    ) -> Constraint {
        return lhs
            .equalToSuperview()
            .inset(
                rhs
            )
            .constraint
    }

    @discardableResult
    public static func == (
        lhs: ConstraintMakerExtendable,
        rhs: PrioritizedLayoutMetric
    ) -> Constraint {
        return lhs
            .equalToSuperview()
            .inset(
                rhs.metric
            )
            .priority(
                rhs.priority
            )
            .constraint
    }

    @discardableResult
    public static func == (
        lhs: ConstraintMakerExtendable,
        rhs: UIView
    ) -> Constraint {
        return lhs == LayoutConstraint(view: rhs)
    }

    @discardableResult
    public static func == (
        lhs: ConstraintMakerExtendable,
        rhs: ConstraintItem
    ) -> Constraint {
        return lhs == LayoutConstraint(constraintItem: rhs)
    }

    @discardableResult
    public static func >= (
        lhs: ConstraintMakerExtendable,
        rhs: LayoutConstraint
    ) -> Constraint {
        var maker: ConstraintMakerEditable

        switch rhs.target {
        case .superview:
            maker = lhs.greaterThanOrEqualToSuperview()
        case .constraintItem(let constraintItem):
            maker =
                lhs.greaterThanOrEqualTo(
                    constraintItem
                )
        case .view(let view):
            maker =
                lhs.greaterThanOrEqualTo(
                    view
                )
        }

        return makeConstraint(
            maker,
            of: rhs
        )
    }

    @discardableResult
    public static func >= (
        lhs: ConstraintMakerExtendable,
        rhs: LayoutMetric
    ) -> Constraint {
        return lhs
            .greaterThanOrEqualToSuperview()
            .inset(
                rhs
            )
            .constraint
    }

    @discardableResult
    public static func >= (
        lhs: ConstraintMakerExtendable,
        rhs: PrioritizedLayoutMetric
    ) -> Constraint {
        return lhs
            .greaterThanOrEqualToSuperview()
            .inset(
                rhs.metric
            )
            .priority(
                rhs.priority
            )
            .constraint
    }

    @discardableResult
    public static func >= (
        lhs: ConstraintMakerExtendable,
        rhs: UIView
    ) -> Constraint {
        return lhs >= LayoutConstraint(view: rhs)
    }

    @discardableResult
    public static func >= (
        lhs: ConstraintMakerExtendable,
        rhs: ConstraintItem
    ) -> Constraint {
        return lhs >= LayoutConstraint(constraintItem: rhs)
    }

    @discardableResult
    public static func <= (
        lhs: ConstraintMakerExtendable,
        rhs: LayoutConstraint
    ) -> Constraint {
        var maker: ConstraintMakerEditable

        switch rhs.target {
        case .superview:
            maker = lhs.lessThanOrEqualToSuperview()
        case .constraintItem(let constraintItem):
            maker =
                lhs.lessThanOrEqualTo(
                    constraintItem
                )
        case .view(let view):
            maker =
                lhs.lessThanOrEqualTo(
                    view
                )
        }

        return makeConstraint(
            maker,
            of: rhs
        )
    }

    @discardableResult
    public static func <= (
        lhs: ConstraintMakerExtendable,
        rhs: LayoutMetric
    ) -> Constraint {
        return lhs
            .lessThanOrEqualToSuperview()
            .inset(
                rhs
            )
            .constraint
    }

    @discardableResult
    public static func <= (
        lhs: ConstraintMakerExtendable,
        rhs: PrioritizedLayoutMetric
    ) -> Constraint {
        return lhs
            .lessThanOrEqualToSuperview()
            .inset(
                rhs.metric
            )
            .priority(
                rhs.priority
            )
            .constraint
    }

    @discardableResult
    public static func <= (
        lhs: ConstraintMakerExtendable,
        rhs: ConstraintItem
    ) -> Constraint {
        return lhs <= LayoutConstraint(constraintItem: rhs)
    }

    @discardableResult
    public static func <= (
        lhs: ConstraintMakerExtendable,
        rhs: UIView
    ) -> Constraint {
        return lhs <= LayoutConstraint(view: rhs)
    }

    private static func makeConstraint(
        _ aMaker: ConstraintMakerEditable,
        of layoutConstraint: LayoutConstraint
    ) -> Constraint {
        var maker = aMaker

        if let multiplier = layoutConstraint.multiplier {
            maker =
                maker.multipliedBy(
                    multiplier
                )
        }

        if let constant = layoutConstraint.constant {
            if layoutConstraint.isRelational {
                maker =
                    maker.offset(
                        constant
                    )
            } else {
                maker =
                    maker.inset(
                        constant
                    )
            }
        }

        if let priority = layoutConstraint.priority {
            return maker
                .priority(
                    priority
                )
                .constraint
        }

        return maker.constraint
    }
}

precedencegroup LayoutPriorityPresendence {
    lowerThan: AdditionPrecedence
    higherThan: ComparisonPrecedence
    associativity: left
}

infix operator ~: LayoutPriorityPresendence
