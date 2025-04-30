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

//   Mail.swift

import Foundation

struct Mail {
    let subject: String?
    let message: String?
    let recipients: [String]?

    init(_ type: MailType) {
        switch type {
        case .report(let assetId):
            self.subject = String(format: String(localized: "mail-report-subject"), assetId)
            self.recipients = [String(localized: "mail-report-address")]
            self.message = nil
        }
    }
}
