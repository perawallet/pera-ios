//
//  Reusable.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

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
