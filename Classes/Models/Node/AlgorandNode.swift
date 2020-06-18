//
//  AlgorandNode.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct AlgorandNode {
    let address: String
    let algodToken: String
    let indexerToken: String
    let algodPort: String
    let indexerPort: String
    let name: String
    let network: API.BaseNetwork
}
