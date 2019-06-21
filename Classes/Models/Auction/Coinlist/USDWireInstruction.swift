//
//  USDWireInstruction.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie

class USDWireInstruction: Mappable {
    
    let bankName: String?
    let bankAddress: String?
    let bankPhone: String?
    let creditTo: String?
    let beneficiaryAddress: String?
    let routingNumber: String?
    let accountNumber: String?
    let swift: String?
    let reference: String?
}

extension USDWireInstruction {
    
    enum CodingKeys: String, CodingKey {
        case bankName = "bank_name"
        case bankAddress = "bank_address"
        case bankPhone = "bank_phone"
        case creditTo = "credit_to"
        case beneficiaryAddress = "beneficiary_address"
        case routingNumber = "routing_number"
        case accountNumber = "account_number"
        case swift = "swift"
        case reference = "reference"
    }
}
