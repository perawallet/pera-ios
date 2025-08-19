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

//   JSONDecoder+Utils.swift

import Foundation

extension JSONDecoder.KeyDecodingStrategy {
    
    static var kebabCase: Self {
        .custom {
            
            let key = $0
                .last?
                .stringValue
                .split(separator: "-")
                .enumerated()
                .map { $0.offset > 0 ? $0.element.capitalized : String($0.element) }
                .joined()
            
            return APICodingKey(stringValue: key ?? "")
        }
    }
}
