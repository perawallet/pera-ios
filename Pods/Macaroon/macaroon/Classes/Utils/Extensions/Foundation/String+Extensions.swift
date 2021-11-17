// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension String {
    public var lastIndex: Index {
        if endIndex == startIndex {
            return endIndex
        }
        return index(before: endIndex)
    }
}

extension String {
    public subscript(safe index: Index?) -> Character? {
        return index
            .unwrapConditionally(where: { indices.contains($0) })
            .unwrap({ self[$0] })
    }

    public func substring(at range: NSRange) -> String {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(start, offsetBy: range.length)
        return String(self[start..<end])
    }
}

extension String {
    public func without(_ string: String) -> String {
        return replacingOccurrences(of: string, with: "")
    }

    public func without(prefix: String) -> String {
        if !hasPrefix(
            prefix
        ) {
            return self
        }

        return String(
            dropFirst(
                prefix.count
            )
        )
    }
}

extension String {
    public func replacingCharacters(in range: NSRange, with replacement: String) -> String {
        return (self as NSString).replacingCharacters(in: range, with: replacement)
    }
}

extension String {
    public func boundingSize(attributes: AttributedTextBuilder.Attribute..., multiline: Bool = true, fittingSize: CGSize = .greatestFiniteMagnitude) -> CGSize {
        let options: NSStringDrawingOptions

        if multiline {
            options = [.usesFontLeading, .usesLineFragmentOrigin, .truncatesLastVisibleLine]
        } else {
            options = [.usesFontLeading]
        }
        let fittingBoundingRect = NSString(string: self).boundingRect(with: fittingSize, options: options, attributes: attributes.asSystemAttributes(), context: nil)
        return CGSize(width: min(fittingBoundingRect.width.ceil(), fittingSize.width), height: min(fittingBoundingRect.height.ceil(), fittingSize.height))
    }
}

extension String {
    public func copyToClipboard() {
        UIPasteboard.general.string = self
    }
}

extension String: Swift.Error {}

extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        return unwrap(
            \.isEmpty,
            or: true
        )
    }

    public var nonNil: String {
        return self ?? ""
    }
}
