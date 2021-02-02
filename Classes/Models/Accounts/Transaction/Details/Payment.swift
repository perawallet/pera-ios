//
//  Payment.swift

import Magpie

class Payment: Model {
    let amount: Int64
    let receiver: String
    let closeAmount: Int64?
    let closeAddress: String?
    
    func amountForTransaction(includesCloseAmount: Bool) -> Int64 {
        if let closeAmount = closeAmount, closeAmount != 0, includesCloseAmount {
            return closeAmount + amount
        }
        return amount
    }
    
    func closeAmountForTransaction() -> Int64? {
        guard let closeAmount = closeAmount, closeAmount != 0 else {
            return nil
        }
        
        return closeAmount
    }
}

extension Payment {
    private enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case receiver = "receiver"
        case closeAmount = "close-amount"
        case closeAddress = "close-remainder-to"
    }
}
