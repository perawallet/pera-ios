// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

/// <note>
/// The base protocol which includes the required styles in a view.
public protocol StyleSheet {}

public struct NoStyleSheet: StyleSheet {
    public init() {}
}
