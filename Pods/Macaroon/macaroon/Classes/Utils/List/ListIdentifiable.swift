// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import UIKit

public protocol ListIdentifiable: UICollectionReusableView {
    static var reuseIdentifier: String { get }
}

extension ListIdentifiable {
    public static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UICollectionReusableView: ListIdentifiable { }
extension UICollectionViewCell: ListIdentifiable {}
