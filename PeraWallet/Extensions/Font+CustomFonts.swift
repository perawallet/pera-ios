// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   Font+CustomFonts.swift

import SwiftUI

extension Font {
    
    enum DMMono: String {
        case regular = "Regular"
        case light = "Light"
        case lightItalic = "LightItalic"
        case italic = "Italic"
        case medium = "Medium"
        case mediumItalic = "MediumItalic"
    }

    enum DMSans: String {
        case regular = "Regular"
        case bold = "Bold"
        case boldItalic = "BoldItalic"
        case italic = "Italic"
        case medium = "Medium"
        case mediumItalic = "MediumItalic"
    }
}

protocol PeraFont {
    var name: String { get }
}

extension PeraFont {
    func size(_ size: CGFloat) -> Font { .custom(name, size: size) }
}

extension Font.DMMono: PeraFont {
    var name: String { "DMMono-\(rawValue)" }
}

extension Font.DMSans: PeraFont {
    var name: String { "DMSans-\(rawValue)" }
}
