//
//  String+Number.swift
//  algorand
//
//  Created by Omer Emre Aslan on 16.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

extension String {
    var digits: String { return filter(("0"..."9").contains) }
    var decimal: Decimal { return Decimal(string: digits) ?? 0 }
}
