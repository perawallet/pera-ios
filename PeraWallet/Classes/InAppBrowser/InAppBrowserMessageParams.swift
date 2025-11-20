// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   InAppBrowserMessageParams.swift

struct URLParams: Decodable {
    let url: String
}

struct URIParams: Decodable {
    let uri: String
}

struct PushWVParams: Decodable {
    let url: String
    let title: String?
    let projectId: String?
    let isFavorite: Bool?
}

struct LogEventParams: Decodable {
    let name: String
    let payload: [String: AnyCodable]?
}

struct NotifyParams: Decodable {
    let type: NotifyType
    let variant: String
    let message: String?
}

enum NotifyType: String, Decodable {
    case haptic
    case sound
    case message
}

struct AnyCodable: Decodable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.typeMismatch(AnyCodable.self,
                DecodingError.Context(codingPath: decoder.codingPath,
                debugDescription: "Unsupported type"))
        }
    }
}
