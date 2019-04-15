//
//  Int64+API.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

extension Int64: ParamsPairValue {
    
    public func asQueryItemValue() -> String? {
        return "\(self)"
    }
}
