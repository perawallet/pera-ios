//
//  UIViewController+Additions.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func displaySimpleAlertWith(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "title-ok".localized, style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
}
