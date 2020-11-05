//
//  Dictionary+ErrorLogParamKeys.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 5.11.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import Foundation

extension Dictionary where Key == ErrorLogParamKeys {
    func transformToAnalyticsFormat() -> [String: Any] {
        var transformed = [String: Any]()
        
        forEach {
            transformed[$0.key.rawValue] = $0.value
        }
        
        return transformed
    }
}
