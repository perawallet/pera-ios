//
//  NumpadView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

enum NumpadValue {
    case number(String?)
    case delete
}

protocol NumpadTypeable {
    
    var value: NumpadValue { get set }
}

class NumpadView: BaseView {
    
}
