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

//   CoinbaseQR.swift

import Foundation

struct CoinbaseQR {
    static func isCoinbaseQR(_ url: URL) -> Bool {
        return url.scheme == "algo"
    }
    
    static func parseQRText(_ url: URL) -> QRText? {
        guard let urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: true
        ) else {
            return nil
        }
        
        if urlComponents.path.isValidatedAddress {
            return QRText(
                mode: .address,
                address: urlComponents.path
            )
        }
        
        guard let assetIDAsString = urlComponents.path.split(separator: "/").first,
              let assetID = Int64(assetIDAsString),
              let queryParameters = url.queryParameters,
              let address = queryParameters[QRText.CodingKeys.address.rawValue] else {
            return nil
        }
        
        return QRText(
            mode: .assetRequest,
            address: address,
            amount: 0,
            asset: assetID
        )
    }
}
