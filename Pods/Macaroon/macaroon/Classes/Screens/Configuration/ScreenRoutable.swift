// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol ScreenRoutable: UIViewController {
    var flowIdentifier: String { get set }
    var pathIdentifier: String { get set }
}
