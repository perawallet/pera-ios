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
//   WCGroupTransactionItemViewModel.swift

import UIKit

class WCGroupTransactionItemViewModel {

    private(set) var hasWarning = false
    private(set) var title: String?
    private(set) var isAlgos = true
    private(set) var amount: String?
    private(set) var assetName: String?
    private(set) var accountInformationViewModel: WCGroupTransactionAccountInformationViewModel?

    init() {
        setHasWarning()
        setTitle()
        setIsAlgos()
        setAmount()
        setAssetName()
        setAccountInformationViewModel()
    }

    private func setHasWarning() {
        hasWarning = true
    }

    private func setTitle() {
        title = ""
    }

    private func setIsAlgos() {
        isAlgos = true
    }

    private func setAmount() {
        amount = ""
    }

    private func setAssetName() {
        assetName = ""
    }

    private func setAccountInformationViewModel() {
        
    }
}
