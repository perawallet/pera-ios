// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol Transition {
    typealias Completion = () -> Void

    var destination: [UIViewController] { get set }
    var completion: Completion? { get set }

    func perform(animated: Bool)
}
