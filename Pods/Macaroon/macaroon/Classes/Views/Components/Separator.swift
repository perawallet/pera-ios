// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

public struct Separator {
    public let color: UIColor
    public let size: CGFloat /// <note> It means width if the separator is vertical and height if the separator is horizontal.
    public let position: Position

    public init(
        color: Color,
        size: CGFloat = 1,
        position: Position = .bottom((0, 0))
    ) {
        self.color = color.color
        self.size = size
        self.position = position
    }
}

extension Separator {
    public enum Position {
        case top(LayoutHorizontalPaddings)
        case left(LayoutVerticalPaddings)
        case bottom(LayoutHorizontalPaddings)
        case right(LayoutVerticalPaddings)
    }
}

extension UIView {
    /// <note> `padding` indicates the distance between separator and the edge.
    @discardableResult
    public func addSeparator(
        _ separator: Separator,
        padding: LayoutMetric = 0
    ) -> UIView {
        let view =
            makeSeparator(
                for: separator
            )

        addSubview(
            view
        )
        view.snp.makeConstraints {
            switch separator.position {
            case .top:
                $0.top == padding
            case .left:
                $0.leading == padding
            case .bottom:
                $0.bottom == padding
            case .right:
                $0.trailing == padding
            }

            makePositionConstraints(
                $0,
                for: separator
            )
        }

        return view
    }

    /// <note> `padding` indicates the distance between separator and aView's edge.
    @discardableResult
    public func attachSeparator(
        _ separator: Separator,
        to aView: UIView,
        margin: LayoutMetric = 0
    ) -> UIView {
        let view =
            makeSeparator(
                for: separator
            )

        addSubview(
            view
        )
        view.snp.makeConstraints {
            switch separator.position {
            case .top:
                $0.bottom == aView.snp.top - margin
            case .left:
                $0.trailing == aView.snp.leading - margin
            case .bottom:
                $0.top == aView.snp.bottom + margin
            case .right:
                $0.leading == aView.snp.trailing + margin
            }

            makePositionConstraints(
                $0,
                for: separator
            )
        }

        return view
    }
}

extension UIView {
    func makeSeparator(
        for separator: Separator
    ) -> UIView {
        let view = BaseView()
        view.backgroundColor = separator.color
        return view
    }

    func makePositionConstraints(
        _ maker: ConstraintMaker,
        for separator: Separator
    ) {
        switch separator.position {
        case .top(let hPaddings),
             .bottom(let hPaddings):
            maker.leading == hPaddings.leading
            maker.trailing == hPaddings.trailing

            maker.fitToHeight(
                separator.size
            )
        case .left(let vPaddings),
             .right(let vPaddings):
            maker.top == vPaddings.top
            maker.bottom == vPaddings.bottom

            maker.fitToWidth(
                separator.size
            )
        }
    }
}
