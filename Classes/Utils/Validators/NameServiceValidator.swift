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

//   NameServiceValidator.swift

import Foundation

struct NameServiceValidator {
    private let nameServiceRegex = #"^([a-z0-9\-]+\.){0,1}([a-z0-9\-]+)(\.[a-z0-9]+)$"#
    
    func validate(_ input: String?) -> Bool {
        guard let text = input, !text.isEmptyOrBlank else {
            return false
        }

        guard let regex = try? NSRegularExpression(pattern: nameServiceRegex) else {
            return false
        }
        
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, options: [.anchored], range: range)
        
        switch matches.count {
        case 1: return true
        default: return false
        }
    }
}
