// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

extension String {
    public func attributed(_ attributes: AttributedTextBuilder.Attribute...) -> NSAttributedString {
        return attributed(attributes)
    }

    public func attributed(_ attributes: [AttributedTextBuilder.Attribute]) -> NSAttributedString {
        let builder = AttributedTextBuilder(self)
        attributes.forEach { builder.addAttribute($0) }
        return builder.build()
    }
}
