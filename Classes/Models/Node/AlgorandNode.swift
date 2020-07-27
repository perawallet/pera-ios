//
//  AlgorandNode.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct AlgorandNode {
    let algodAddress: String
    let indexerAddress: String
    let algodToken: String
    let indexerToken: String
    let name: String
    let network: API.BaseNetwork
}
