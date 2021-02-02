//
//  Dictionary+ErrorLogParamKeys.swift

import Foundation

extension Dictionary where Key == AnalyticsParameter {
    func transformToAnalyticsFormat() -> [String: Any] {
        var transformed = [String: Any]()
        
        forEach {
            transformed[$0.key.rawValue] = $0.value
        }
        
        return transformed
    }
}
