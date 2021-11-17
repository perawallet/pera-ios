// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

extension Dictionary {
    public func findFirst<T>(nonNil transform: (Value) -> T?) -> (Key, T)? {
        for item in self {
            if let transformedValue = transform(item.value) {
                return (item.key, transformedValue)
            }
        }
        return nil
    }
}
