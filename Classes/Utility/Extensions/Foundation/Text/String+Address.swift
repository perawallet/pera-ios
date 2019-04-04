//
//  String+Address.swift
//  algorand
//
//  Created by Omer Emre Aslan on 4.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation

private let validatedAdressLength = 58

extension String {
    
    func isValidatedAdress() -> Bool {
        return count == validatedAdressLength
    }
}
