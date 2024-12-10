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

//   IncomingASAsDetailSuccessResultScreenViewModel.swift

import MacaroonUIKit
import UIKit

struct IncomingASAsDetailSuccessResultScreenViewModel: SuccessResultScreenViewModel {
    var title: TextProvider?
    var detail: TextProvider?
    
    init(title: String, detail: String) {
        self.title = title
            .bodyLargeMedium(alignment: .center)
        self.detail =  detail
            .bodyRegular(alignment: .center)
    }
}
