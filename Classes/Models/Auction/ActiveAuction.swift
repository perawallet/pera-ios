//
//  ActiveAuction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class ActiveAuction: Mappable {
    
    let id: Int
    let currentPrice: Int?
    let estimatedFinishTime: String?
    let remainingAlgos: Int?
    let bidCount: Int?
    let addressCount: Int?
    let status: AuctionStatus?
}

extension ActiveAuction {
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case currentPrice = "CurrentPrice"
        case estimatedFinishTime = "EstimatedFinishTime"
        case remainingAlgos = "RemainingAlgos"
        case bidCount = "NumberOfBids"
        case addressCount = "NumberOfAddresses"
        case status = "Status"
    }
}

enum AuctionStatus: String, Mappable {
    case announced = "Announced"
    case running = "Running"
    case closed = "Closed"
}
