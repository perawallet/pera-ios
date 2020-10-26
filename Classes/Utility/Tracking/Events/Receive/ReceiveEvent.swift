//
//  ReceiveEvent.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

struct ReceiveEvent: TrackableEvent {
    var eventKey: String {
        return "receive_\(flow.rawValue)"
    }
    
    let flow: ReceiveEventFlow
    let address: String
    
    var parameters: [String: Any]? {
        return [
            "address": address
        ]
    }
}

enum ReceiveEventFlow: String {
    case detail = "detail"
    case tab = "tab"
    case accounts = "account"
    case contact = "contact"
    case contactDetail = "contact_detail"
    case transactionDetailContact = "transaction_contact"
    case transactionDetailAccount = "transaction_account"
}
