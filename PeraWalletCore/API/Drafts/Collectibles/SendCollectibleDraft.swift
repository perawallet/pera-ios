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

//   SendCollectibleDraft.swift

import UIKit

public struct SendCollectibleDraft {
    public let fromAccount: Account
    public let collectibleAsset: CollectibleAsset
    public let image: UIImage?

    public var toAccount: Account?
    public var toContact: Contact?
    public var toNameService: NameService?
    public var fee: UInt64?
    public var isReceiverOptingInToCollectible: Bool

    public var receiverAddress: String? {
        toAccount?.address ??
        toContact?.address ??
        toNameService?.address
    }

    public mutating func resetReceiver() {
        toAccount = nil
        toContact = nil
        toNameService = nil
    }
}
