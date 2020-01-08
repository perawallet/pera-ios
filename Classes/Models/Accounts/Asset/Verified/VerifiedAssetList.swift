//
//  VerifiedAssetList.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.01.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Magpie

class VerifiedAssetList: Model {
    let count: Int
    let next: String?
    let previous: String?
    let results: [VerifiedAsset]
}
