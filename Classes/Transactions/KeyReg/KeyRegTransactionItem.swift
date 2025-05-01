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

//   KeyRegTransactionItem.swift

import Foundation

struct KeyRegTransactionItem: Identifiable {
    let id = UUID()
    let title: String
    var value: String
    let hasSeparator: Bool
    let action: String?
    
    init(
        title: String,
        value: String,
        hasSeparator: Bool,
        action: String? = nil
    ) {
        self.title = title
        self.value = value
        self.hasSeparator = hasSeparator
        self.action = action
    }
}
