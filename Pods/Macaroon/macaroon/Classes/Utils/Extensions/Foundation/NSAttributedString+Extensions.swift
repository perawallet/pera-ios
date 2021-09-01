// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension NSAttributedString {
    public func boundingSize(multiline: Bool = true, fittingSize: CGSize = .greatestFiniteMagnitude) -> CGSize {
        let options: NSStringDrawingOptions

        if multiline {
            options = [.usesFontLeading, .usesLineFragmentOrigin, .truncatesLastVisibleLine]
        } else {
            options = [.usesFontLeading]
        }
        let fittingBoundingRect = boundingRect(with: fittingSize, options: options, context: nil)
        return CGSize(width: min(fittingBoundingRect.width.ceil(), fittingSize.width), height: min(fittingBoundingRect.height.ceil(), fittingSize.height))
    }
}

extension Optional where Wrapped == NSAttributedString {
    public var isNilOrEmpty: Bool {
        return unwrap(
            {
                $0.string.isEmpty
            },
            or: true
        )
    }
}
