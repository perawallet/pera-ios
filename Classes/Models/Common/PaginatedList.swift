//
//  PaginatedList.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

class PaginatedList<T: Model>: Model {
    let count: Int
    let next: String?
    let previous: String?
    let results: [T]
}
