// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public typealias BaseStyle<T: BaseStyleAttribute> = [T]

extension BaseStyle {
    public func mutate(
        by modifiers: BaseStyle<Element>...
    ) -> Self {
        /// <note>
        /// The modifier style overrides the attributes of the self style.
        let union = modifiers
            .reduce([]) {
                Set($1).union(
                    Set($0)
                )
            }
            .union(
                Set(self)
            )
        return Array(union)
    }
}

public protocol BaseStyleAttribute: Hashable {
    var id: String { get }

    static func backgroundColor(_ color: Color) -> Self
    static func tintColor(_ color: Color) -> Self
}

extension BaseStyleAttribute {
    public func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(id)
    }

    public static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.id == rhs.id
    }
}

extension BaseStyleAttribute {
    static func getBackgroundColorAttributeId() -> String {
        return "backgroundColor"
    }

    static func getTintColorAttributeId() -> String {
        return "tintColor"
    }
}
