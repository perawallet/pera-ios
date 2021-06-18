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
//   WCTransactionDappMessageViewModel.swift

import UIKit
import Macaroon

class WCTransactionDappMessageViewModel {
    private(set) var image: ImageSource?
    private(set) var name: String?
    private(set) var message: String?

    init(session: WalletConnectSession, imageSize: CGSize) {
        setImage(from: session, and: imageSize)
        setName(from: session)
        setMessage(from: session)
    }

    private func setImage(from session: WalletConnectSession, and imageSize: CGSize) {
        image = PNGImageSource(
            url: session.dAppInfo.peerMeta.icons.first,
            color: nil,
            size: .resize(imageSize, .aspectFit),
            shape: .circle,
            placeholder: nil,
            forceRefresh: false
        )
    }

    private func setName(from session: WalletConnectSession) {
        name = session.dAppInfo.peerMeta.name
    }

    private func setMessage(from session: WalletConnectSession) {
        message = session.dAppInfo.peerMeta.description
    }
}
