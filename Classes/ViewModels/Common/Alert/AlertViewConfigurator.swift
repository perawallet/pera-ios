//
//  AlertViewConfigurator.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

struct AlertViewConfigurator {
    
    let title: String
    let image: UIImage?
    let explanation: String
    let actionTitle: String?
    let actionHandler: EmptyHandler?
    
    init(title: String, image: UIImage?, explanation: String, actionTitle: String? = nil, actionHandler: EmptyHandler? = nil) {
        self.title = title
        self.image = image
        self.explanation = explanation
        self.actionTitle = actionTitle
        self.actionHandler = actionHandler
    }
}
