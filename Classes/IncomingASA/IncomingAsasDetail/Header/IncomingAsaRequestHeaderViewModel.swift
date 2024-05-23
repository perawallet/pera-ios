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

//   IncomingAsaRequestHeaderViewModel.swift

import Foundation
import MacaroonUIKit
import MacaroonURLImage

struct IncomingAsaRequestHeaderViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var subTitle: TextProvider?

    init(_ draft: WCSessionConnectionDraft) {
        bindTitle(draft)
        bindSubtitle(draft)
    }
}

extension IncomingAsaRequestHeaderViewModel {
    
    private mutating func bindTitle(_ draft: WCSessionConnectionDraft) {
        let dAppName = draft.dappName
        let dAppNameAttributes = Typography.bodyLargeMediumAttributes(alignment: .center)

        let aTitle =
        "250.00 USDC"
//            .localized(params: dAppName)
            .titleMedium(alignment: .center)
//            .addAttributes(
//                to: dAppName,
//                newAttributes: dAppNameAttributes
//            )
        title = aTitle
    }

    private mutating func bindSubtitle(_ draft: WCSessionConnectionDraft) {
        let dAppName = draft.dappName
        let dAppNameAttributes = Typography.bodyLargeMediumAttributes(alignment: .center)

        let aTitle =
        "$203.49"
//            .localized(params: dAppName)
            .bodyRegular(alignment: .center)
//            .addAttributes(
//                to: dAppName,
//                newAttributes: dAppNameAttributes
//            )
        subTitle = aTitle
    }
}
