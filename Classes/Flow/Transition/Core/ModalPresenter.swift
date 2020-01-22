//
//  ModalPresenter.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum ModalSize {
    case compressed
    case half
    case expanded
    case full
    case custom(CGSize)
}

extension ModalSize: Equatable {
    static func == (lhs: ModalSize, rhs: ModalSize) -> Bool {
        switch (lhs, rhs) {
        case (.compressed, .compressed),
             (.half, .half),
             (.expanded, .expanded),
             (.full, .full):
            return true
        case (.custom(let size1), .custom(let size2)):
            return size1 == size2
        default:
            return false
        }
    }
}

protocol ModalPresenter: UIViewControllerTransitioningDelegate {
    typealias Configuration = ModalConfiguration
    
    var config: Configuration { get }
    
    init(config: Configuration, initialModalSize: ModalSize)
}
