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
}
