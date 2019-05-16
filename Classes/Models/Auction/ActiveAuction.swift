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
    let estimatedFinishTime: Date?
    let remainingAlgos: Int64?
    let bidCount: Int?
    let addressCount: Int?
    let status: AuctionStatus?
    let estimatedDepositRoundStart: Date?
    let estimatedAuctionRoundStart: Date?
    let currentRound: Int?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        currentPrice = try container.decodeIfPresent(Int.self, forKey: .currentPrice)
        
        let finishTimeString = try container.decodeIfPresent(String.self, forKey: .estimatedFinishTime)
        estimatedFinishTime = finishTimeString?.toDate()?.date
        
        remainingAlgos = try container.decodeIfPresent(Int64.self, forKey: .remainingAlgos)
        bidCount = try container.decodeIfPresent(Int.self, forKey: .bidCount)
        addressCount = try container.decodeIfPresent(Int.self, forKey: .addressCount)
        status = try container.decodeIfPresent(AuctionStatus.self, forKey: .status)
        
        let estimatedDepositRoundStartString = try container.decodeIfPresent(String.self, forKey: .estimatedDepositRoundStart)
        estimatedDepositRoundStart = estimatedDepositRoundStartString?.toDate()?.date
        
        let estimatedAuctionRoundStartString = try container.decodeIfPresent(String.self, forKey: .estimatedAuctionRoundStart)
        estimatedAuctionRoundStart = estimatedAuctionRoundStartString?.toDate()?.date
        
        currentRound = try container.decodeIfPresent(Int.self, forKey: .currentRound)
    }
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
        case estimatedDepositRoundStart = "EstimatedDepositRoundStart"
        case estimatedAuctionRoundStart = "EstimatedAuctionRoundStart"
        case currentRound = "CurrentRound"
    }
}

enum AuctionStatus: String, Mappable {
    case announced = "Announced"
    case running = "Running"
    case closed = "Closed"
}
