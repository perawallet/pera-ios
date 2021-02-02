//
//  Reusable.swift

import UIKit

protocol Reusable: AnyObject {
    
    static var reusableIdentifier: String { get }
}

extension Reusable where Self: UICollectionViewCell {
    
    static var reusableIdentifier: String {
        return String(describing: Self.self)
    }
}

extension Reusable where Self: UICollectionReusableView {
    
    static var reusableIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UICollectionReusableView: Reusable { }
