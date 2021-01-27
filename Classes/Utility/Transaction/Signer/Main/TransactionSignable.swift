//
//  TransactionSignable.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import Foundation

protocol TransactionSignable: class {
    func sign(_ data: Data?, with privateData: Data?) -> Data?
}
