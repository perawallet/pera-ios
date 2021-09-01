// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

#if DEBUG
import SwiftUI

@available(iOS 13, *)
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController

        func makeUIViewController(
            context: Context
        ) -> UIViewController {
            return viewController
        }

        func updateUIViewController(
            _ uiViewController: UIViewController,
            context: Context
        ) {}
    }

    public func toPreview() -> some SwiftUI.View {
        Group {
            Preview(viewController: self)
                .previewDevice("iPhone SE (1st generation)")
                .previewDisplayName("Small")
            Preview(viewController: self)
                .previewDevice("iPhone 11 Pro")
                .previewDisplayName("Medium")
            Preview(viewController: self)
                .previewDevice("iPhone 12 Pro Max")
                .previewDisplayName("Large")
        }
    }
}
#endif
