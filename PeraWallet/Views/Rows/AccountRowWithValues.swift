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

//   AccountRowWithValues.swift

import SwiftUI

struct AccountRowWithValues: View {
    
    // MARK: - Properties
    
    let image: ImageType
    let title: String
    let subtitle: String?
    let primaryValue: String
    let secondaryValue: String
    
    // MARK: - Body
    
    var body: some View {
        CoreAccountRow(image: image, title: title, subtitle: subtitle) {
            VStack(alignment: .trailing) {
                Text(primaryValue)
                    .font(.DMSans.medium.size(15.0))
                    .foregroundStyle(Color.Text.main)
                Text(secondaryValue)
                    .font(.DMSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.gray)
            }
        }
    }
}
