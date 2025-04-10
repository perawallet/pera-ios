// Copyright 2022 Pera Wallet, LDA

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
//  String+Localization.swift

import Foundation

extension String {
    var localized: String {
        return localizedString()
    }
    
    func localized(params: CVarArg...) -> String {
        let value = localizedString()
        return formattedString(
            value,
            params: params
        )
    }
}

extension String {
    private func localizedString() -> String {
        return NSLocalizedString(
            self,
            comment: ""
        )
    }

    func formattedString(
        _ value: String,
        params: CVarArg...
    ) -> String {
        return String(
            format: value,
            arguments: params
        )
    }
}
