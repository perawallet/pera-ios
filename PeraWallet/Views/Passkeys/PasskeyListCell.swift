// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import pera_wallet_core

//TODO: This is a temporary placeholder - update when we have final designs
struct PasskeyListCell: View {
    
    // MARK: - Properties
    @State var viewModel: PasskeyListCellViewModel
        
    // MARK: - Body
    var body: some View {
        HStack {
            Image(.Settings.Icon.passkeys)
                .resizable()
                .foregroundStyle(Color.Text.main)
                .frame(width: 24.0, height: 24.0)
                .padding(.trailing, 16.0)
            VStack(alignment: .leading, spacing: 4.0) {
                Text(viewModel.passkey.displayName)
                    .font(.dmSans.bold.size(15.0))
                    .foregroundStyle(Color.Text.main)
                Text(viewModel.passkey.origin)
                    .font(.dmSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.gray)
                Text(viewModel.passkey.lastUsedDisplay)
                    .font(.dmSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.gray)
            }
            Spacer()
            Image(.iconNextDisabled)
                .resizable()
                .foregroundStyle(Color.Text.main)
                .frame(width: 24.0, height: 24.0)
        }
        .padding(.leading, 24.0)
        .frame(height: 64.0)
        .swipeActions {
            SwiftUI.Button(String(localized: "settings-passkeys-delete")) {
                viewModel.deletePasskey()
            }
            .tint(.red)
        }
    }
}
