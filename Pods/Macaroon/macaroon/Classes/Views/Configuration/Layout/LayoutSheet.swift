// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

/// <note>
/// The base protocol which includes the required metrics in a view.
public protocol LayoutSheet {
    init(_ family: LayoutFamily)
}

extension LayoutSheet {
    public init() {
        self.init(LayoutFamily.current)
    }
}

public enum LayoutFamily {
    /// <note>
    /// iPhone 5{s, c}, iPhone SE 1.Gen
    case extraSmall
    /// <note>
    /// iPhone 6{s}, iPhone 7, iPhone 8, iPhone SE 2.Gen
    case small
    /// <note>
    /// iPhone 6s plus, iPhone 7s plus, iPhone 8s plus, iPhone X{S}, iPhone 11 Pro, iPhone 12, iPhone 12 Pro, iPhone 12 Mini
    case medium
    /// <note>
    /// iPhone XS Max, iPhone XR, iPhone 11, iPhone 11 Pro Max, iPhone 12 Pro Max
    case large
    /// <note>
    /// iPads
    case extraLarge

    public static let current = getCurrentLayoutFamily()
}

extension LayoutFamily {
    public static func getCurrentLayoutFamily() -> LayoutFamily {
        switch UIScreen.main.traitCollection.userInterfaceIdiom {
        case .pad:
            return .extraLarge
        default:
            switch UIScreen.main.bounds.height {
            case 0...568: return .extraSmall
            case 569...667: return .small
            case 668...844: return .medium
            default: return .large
            }
        }
    }
}

public struct NoLayoutSheet: LayoutSheet {
    public init(
        _ family: LayoutFamily
    ) {}
}
