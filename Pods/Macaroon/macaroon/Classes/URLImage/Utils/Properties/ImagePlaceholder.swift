// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public struct ImagePlaceholder {
    public let image: AssetImageSource?
    public let text: EditText?

    public init(
        image: AssetImageSource? = nil,
        text: EditText? = nil
    ) {
        self.image = image
        self.text = text
    }
}
