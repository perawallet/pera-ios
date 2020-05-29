//
//  String+Empty.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

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
