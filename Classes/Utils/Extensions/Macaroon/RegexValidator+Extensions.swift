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

//   RegexValidator+Extensions.swift

import Foundation
import MacaroonForm

extension RegexValidator {
    init(
        regex: Regex,
        optional: Bool = false,
        failMessage: FailMessage? = nil
    ) {
        self.init(
            regex: regex.rawValue,
            optional: optional,
            failMessage: failMessage
        )
    }
}

extension RegexValidator {
    func validate(_ text: String?, _ handler: (RegexValidation) -> Void) {
        guard let preparedText = prepareForValidation(text) else {
            handler(.failure)
            return
        }
        
        let validationResult: Validation = validate(preparedText)
        
        switch validationResult {
        case .success:
            handler(.success(preparedText))
        case .failure:
            handler(.failure)
        }
    }
    
    private func prepareForValidation(_ query: String?) -> String? {
        guard let text = query?.trimmed.lowercased(),
              !text.isEmptyOrBlank else {
            return nil
        }
        
        return text
    }
}

extension RegexValidator {
    enum Regex: String {
        case nameService = #"^([a-z0-9\-]+\.){0,1}([a-z0-9\-]+)(\.[a-z0-9]+)$"#
    }
}

enum RegexValidation {
    case success(String?)
    case failure
}
