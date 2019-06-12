//
//  Bid.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

enum BidStatus: String, Mappable {
    case queued = "Queued"
    case pending = "Pending"
    case accepted = "Accepted"
    case retracted = "Retracted"
    case successful = "Successful"
    case unsuccessful = "Unsuccessful"
    case paid = "Paid"
}

class Bid: Mappable {
    
    let bidderAddress: String?
    let amount: Int?
    let maxPrice: Int?
    let id: Int
    let auctionAddress: String
    let auctionID: Int?
    let status: BidStatus?
}

extension Bid {
    
    enum CodingKeys: String, CodingKey {
        case bidderAddress = "BidderAddress"
        case amount = "Amount"
        case maxPrice = "MaxPrice"
        case id = "ID"
        case auctionAddress = "AuctionAddress"
        case auctionID = "AuctionID"
        case status = "Status"
    }
}
