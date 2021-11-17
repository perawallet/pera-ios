// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol NavigationBarTitle {}

extension String: NavigationBarTitle {}

extension UIView: NavigationBarTitle {}
