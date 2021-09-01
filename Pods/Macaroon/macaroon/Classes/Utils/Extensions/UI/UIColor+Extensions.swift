// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension UIColor {
    public var hex: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let rgb: Int = (Int)(red * 255) << 16 |
            (Int)(green * 255) << 8 |
            (Int)(blue * 255) << 0

        return String(format: "#%06x", rgb)
    }

    public convenience init(hex: String) {
        let someHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: someHex)

        if someHex.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0

        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
