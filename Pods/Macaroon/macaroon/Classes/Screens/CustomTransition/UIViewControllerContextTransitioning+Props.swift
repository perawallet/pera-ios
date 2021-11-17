// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

extension UIViewControllerContextTransitioning {
    public var sourceViewController: UIViewController? {
        return viewController(
            forKey: .from
        )
    }
    public var sourceView: UIView? {
        return sourceViewController?.view
    }
    public var sourceFinalFrame: CGRect? {
        return sourceViewController.unwrap {
            return finalFrame(
                for: $0
            )
        }
    }

    public var destinationViewController: UIViewController? {
        return viewController(
            forKey: .to
        )
    }
    public var destinationView: UIView? {
        return destinationViewController?.view
    }
    public var destinationFinalFrame: CGRect? {
        return destinationViewController.unwrap {
            return finalFrame(
                for: $0
            )
        }
    }
}
