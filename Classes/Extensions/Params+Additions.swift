//
//  Params+Additions.swift
//  algorand
//
//  Created by Omer Emre Aslan on 20.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation
import Magpie

extension Params {
    mutating func appendIfPresent(
        _ value: ParamsPairValue?,
        for key: ParamsPairKey
        ) {
        guard let v = value else {
            return
        }
        append(.custom(key: key, value: v))
    }
    
    mutating func appendAsNull(_ value: ParamsPairValue?, for key: ParamsPairKey) {
        guard let v = value else {
            append(.custom(key: key, value: NSNull()))
            return
        }
        
        append(.custom(key: key, value: v))
    }
}
