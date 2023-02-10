// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ByteSizeValidator.swift

import Foundation
import MacaroonForm

struct ByteSizeValidator {
    func validate(
        byteArray: [UInt8],
        maxSize: Int
    ) -> Validation {
        if byteArray.count > maxSize {
            return .failure(Error.exceededSize(byteArray.count - maxSize))
        }
        
        return .success
    }
}

extension ByteSizeValidator {
    enum Error: ValidationError {
        case exceededSize(Int)
    }
}
