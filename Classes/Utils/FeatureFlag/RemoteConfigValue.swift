// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RemoteConfigValue.swift

import Foundation

enum RemoteConfigValue {
    case bool(Bool)
    case string(String)
    case int(Int)
    case double(Double)
    case dictionary([String: Any])
    case data(Data)
    
    var asNSObject: NSObject {
        switch self {
        case .bool(let value):
            return NSNumber(value: value)
        case .string(let value):
            return value as NSString
        case .int(let value):
            return NSNumber(value: value)
        case .double(let value):
            return NSNumber(value: value)
        case .dictionary(let value):
            if let data = try? JSONSerialization.data(withJSONObject: value),
               let string = String(data: data, encoding: .utf8) {
                return string as NSString
            }
            return "" as NSString
        case .data(let value):
            return value as NSObject
        }
    }

    var valueType: Any.Type {
        switch self {
        case .bool: return Bool.self
        case .string: return String.self
        case .int: return Int.self
        case .double: return Double.self
        case .dictionary: return [String: Any].self
        case .data: return Data.self
        }
    }
}
