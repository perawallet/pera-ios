//
//  TransactionData.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Foundation

class TransactionData {
    private(set) var unsignedTransaction: Data?
    private(set) var signedTransaction: Data?

    func setUnsignedTransaction(_ data: Data) {
        unsignedTransaction = data
    }

    func setSignedTransaction(_ data: Data) {
        signedTransaction = data
    }
}
