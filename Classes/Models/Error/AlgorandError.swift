// Copyright 2019 Algorand, Inc.

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

final class AlgorandError: ALGResponseModel & Encodable {
    var debugData: Data?

    let type: String
    let message: String?

    init(_ apiModel: APIModel = APIModel()) {
        self.type = apiModel.type
        self.message = apiModel.fallbackMessage
    }
}

extension AlgorandError {
    struct APIModel: ALGAPIModel {
        let type: String
        let fallbackMessage: String?

        init() {
            self.type = ""
            self.fallbackMessage = nil
        }
    }
}

extension AlgorandError {
    enum ErrorType: String {
        case deviceAlreadyExists = "DeviceAlreadyExistsException"
    }
}
