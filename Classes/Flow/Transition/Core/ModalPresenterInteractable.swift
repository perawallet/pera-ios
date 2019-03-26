//
//  ModalPresenterInteractable.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

protocol ModalPresenterInteractable {
    
    func changeModalSize(to newModalSize: ModalSize, animated: Bool)
    func changeModalSize(to newModalSize: ModalSize, animated: Bool, then completion: (() -> Void)?)
}
