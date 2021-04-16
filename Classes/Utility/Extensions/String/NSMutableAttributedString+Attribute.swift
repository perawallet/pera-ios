// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   NSMutableAttributedString+Attribute.swift

import UIKit

extension NSMutableAttributedString {
    func addFont(_ font: UIFont, to string: String) {
        let range = (self.string as NSString).range(of: string)
        addAttribute(.font, value: font, range: range)
    }

    func addColor(_ color: UIColor, to string: String) {
        let colorRange = (self.string as NSString).range(of: string)
        addAttribute(.foregroundColor, value: color, range: colorRange)
    }

    func addLineHeight(_ height: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = height
        addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: string.count))
    }
}
