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

//   ContactDataProvider.swift

import pera_wallet_core

enum ContactDataProvider {
    
    struct ContactData {
        let image: ImageType
        let title: String
        let subtitle: String?
    }
    
    static func data(contact: Contact) -> ContactData? {
        
        guard let address = contact.address else { return nil }
        
        let title = contact.name ?? address.shortAddressDisplay
        let subtitle = contact.name != nil ? address.shortAddressDisplay : nil
        let image: ImageType
        
        if let imageData = contact.image {
            image = .data(data: imageData)
        } else {
            image = .icon(data: ImageType.IconData(image: .Icons.user, tintColor: .Wallet.wallet1, backgroundColor: .Wallet.wallet1Icon))
        }
        
        return ContactData(image: image, title: title, subtitle: subtitle)
    }
}
