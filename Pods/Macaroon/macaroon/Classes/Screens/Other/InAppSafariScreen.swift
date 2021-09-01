// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SafariServices
import UIKit

open class InAppSafariScreen:
    SFSafariViewController,
    ScreenRoutable {
    public var flowIdentifier: String = ""
    public var pathIdentifier: String = ""
}
