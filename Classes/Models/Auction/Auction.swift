//
//  Auction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class Auction: Mappable {
    
    let auctionAddress: String
    let id: Int
    let bankAddress: String
    let dispensingAddress: String
    let lastPrice: Int
    let depositRound: Int
    let firstRound: Int
    let priceChunkRounds: Int
    let chunkCount: Int
    let maximumPriceMultiple: Int
    let algos: Int
    let minimumBidAlgos: Int
}

extension Auction {
    
    enum CodingKeys: String, CodingKey {
        case auctionAddress = "AuctionAddress"
        case id = "ID"
        case bankAddress = "BankAddress"
        case dispensingAddress = "DispensingAddress"
        case lastPrice = "LastPrice"
        case depositRound = "DepositRound"
        case firstRound = "FirstRound"
        case priceChunkRounds = "PriceChunkRounds"
        case chunkCount = "NumChunks"
        case maximumPriceMultiple = "MaxPriceMultiple"
        case algos = "NumAlgos"
        case minimumBidAlgos = "MinBidAlgos"
    }
}
