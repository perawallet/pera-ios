//
//  Optional+Nil.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 12.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        guard let strongSelf = self else {
            return true
        }
        return strongSelf.isEmptyOrBlank
    }
}

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }

    var nonEmpty: Wrapped? {
        isNilOrEmpty ? nil : self
    }
}
