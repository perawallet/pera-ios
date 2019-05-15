//
//  AuctionDraft.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

struct AuctionDraft {
    
    let accessToken: String
    let topCount: Int?
    
    init(accessToken: String, topCount: Int? = nil) {
        self.accessToken = accessToken
        self.topCount = topCount
    }
}
