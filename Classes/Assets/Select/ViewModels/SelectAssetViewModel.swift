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
//  SelectAssetViewModel.swift

import UIKit

class SelectAssetViewModel {
    private(set) var accountName: String?
    private(set) var accountImage: UIImage?

    init(account: Account) {
        setAccountName(from: account)
        setAccountImage(from: account)
    }

    private func setAccountName(from account: Account) {
        accountName = account.name
    }

    private func setAccountImage(from account: Account) {
        accountImage = account.accountImage()
    }
}
