//
//  ChartData.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 22.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class ChartData: Mappable {
    
    let round: Int?
    let remainingAlgos: Int?
}

extension ChartData {
    
    enum CodingKeys: String, CodingKey {
        case round = "round"
        case remainingAlgos = "remaining_algos"
    }
}
