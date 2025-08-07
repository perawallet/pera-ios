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

//
//  AlgorandError.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class AlgorandError: ALGAPIModel {
    let type: String?
    let message: String?

    init() {
        self.type = nil
        self.message = nil
    }
}

extension AlgorandError {
    private enum CodingKeys:
        String,
        CodingKey {
        case type
        case message = "fallback_message"
    }
}

enum APIErrorType: String {
    case deviceAlreadyExists = "DeviceAlreadyExistsException"
    case tinymanExcessAmount = "TinymanExcessAmountError"
}

extension APIError {
    func getDictFromResponseData() -> [String: Any]? {
        do {
            // Convert the JSON data to a dictionary
            guard let jsonData = self.responseData,
                  let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                  let data = json["data"] as? [String: Any] else {
                return nil
            }            
            return data
        }
    }
}
