//
//  String+Address.swift

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

    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
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
