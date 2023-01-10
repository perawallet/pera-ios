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

//   FavouriteDappDetails.swift

import Foundation

struct DiscoverFavouriteDappDetails: Codable {
    let action: String
    let payload: PayloadData
    
    init(
        name:  String?,
        url: URL?
    ) {
        self.action = "handleBrowserFavoriteButtonClick"
        self.payload = PayloadData(
            name: name,
            url: url,
            logo: nil
        )
    }
    
    func getStringData() -> String? {
        let jsonEncoder = JSONEncoder()
        
        guard let encodedData = try? jsonEncoder.encode(self) else {
            return nil
        }
        
        let stringData = String(data: encodedData, encoding: String.Encoding.utf8)
        
        return stringData
    }
    
    struct PayloadData: Codable {
        let name: String?
        let url: URL?
        let logo: String?
    }
}
