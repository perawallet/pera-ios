//
//  String+Empty.swift

import Foundation

extension String {
    func isUnknown() -> Bool {
        return self == "title-unknown".localized
    }
    
    var isEmptyOrBlank: Bool {
        if isEmpty {
            return true
        }
        return allSatisfy { $0.isWhitespace }
    }
    
    func addByteLimiter(maximumLimitInByte: Int) -> String {
        guard let utf8DecodedData = data(using: .utf8),
            let utf8DecodedString = String(data: utf8DecodedData, encoding: .utf8) else {
                return self
        }
        
        var byteLimitedString = utf8DecodedString
        while byteLimitedString.count > 1024 {
            byteLimitedString.removeLast(1)
        }
        
        return byteLimitedString
    }
}
