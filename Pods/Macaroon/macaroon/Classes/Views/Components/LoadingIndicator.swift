// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol LoadingIndicator: UIView {
    init()

    var isAnimating: Bool { get }

    func startAnimating()
    func stopAnimating()
}

extension LoadingIndicator {
    public static var identifier: String {
        return String(describing: Self.self)
    }
}

extension UIActivityIndicatorView: LoadingIndicator { }

extension UIActivityIndicatorView.Style {
    public static var preferred: Self {
        if #available(iOS 13, *) {
            return .medium
        }

        return .white
    }
}
