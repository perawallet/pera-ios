//
//  TransactionDataBuildable.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Foundation

protocol TransactionDataBuildable: class {
    var params: TransactionParams? { get }
    var draft: TransactionSendDraft? { get }

    func composeData() -> Data?
}
