// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol URLImagePlaceholderViewStyleSheet: StyleSheet {
    var background: ViewStyle { get }
    var image: ImageStyle { get }
    var text: TextStyle { get }
}
