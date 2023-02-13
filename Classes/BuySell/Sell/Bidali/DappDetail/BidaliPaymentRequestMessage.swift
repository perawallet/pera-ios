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

//   BidaliPaymentRequestMessage.swift

import Foundation

struct BidaliPaymentRequestMessage: Decodable {
    let request: BidaliPaymentRequest?
}

struct BidaliPaymentRequest: Decodable {
    /// The address to send to.
    let address: String?
    /// The amount to send.
    let amount: String?
    /// The protocol of the currency the user has chosen to pay with, this is unique for each currency.
    let `protocol`: BidaliPaymentCurrency?
    /// The extraId that must be passed as a note for the payment to be credited appropriately to the order.
    let extraId: String?
}
