//
//  String+Address.swift
//  algorand
//
//  Created by Omer Emre Aslan on 4.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

let validatedAddressLength = 58
let defaultParticipationKey = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

extension String {
    func isValidatedAddress() -> Bool {
        return count == validatedAddressLength
    }
    
    func shortAddressDisplay() -> String {
        return String(prefix(6)) + "..." + String(suffix(6))
    }
}

extension Optional where Wrapped == String {
    func shortAddressDisplay() -> String? {
        guard let string = self else {
            return self
        }
        return string.shortAddressDisplay()
    }
}
