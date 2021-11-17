// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

/// <mark>
/// Colors
public func rgb(
    _ red: CGFloat,
    _ green: CGFloat,
    _ blue: CGFloat
) -> UIColor {
    return rgba(
        red,
        green,
        blue, 1.0
    )
}

public func rgba(
    _ red: CGFloat,
    _ green: CGFloat,
    _ blue: CGFloat,
    _ alpha: CGFloat
) -> UIColor {
    return UIColor(
        red: red,
        green: green,
        blue: blue,
        alpha: min(1, max(0, alpha))
    )
}

public func col(
    _ named: String
) -> UIColor {
    guard let color = UIColor(named: named) else {
        mc_crash(.colorNotFound(named))
    }
    return color
}

/// <mark>
/// Images
public func img(_ named: String) -> UIImage {
    guard let image = UIImage(named: named) else {
        mc_crash(.imageNotFound(named))
    }
    return image
}

/// <mark>
/// Localization
extension String {
    public func localized(_ args: CVarArg...) -> String {
        return localized(
            args: args
        )
    }

    public func localized(args: [CVarArg]) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: args)
    }
}

extension RawRepresentable where RawValue == String {
    public func localized(_ args: CVarArg...) -> String {
        return localized(
            args: args
        )
    }

    public func localized(args: [CVarArg]) -> String {
        return rawValue.localized(
            args: args
        )
    }
}
