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

struct PasskeyDisabledView: View {
    func openSettingsAction() -> Void {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
        
    // MARK: - Body
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 20.0) {
                Spacer()
                Image(.Passkeys.passkeysWarningHeader)
                Text("settings-passkeys-description")
                    .font(.DMSans.regular.size(15.0))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.Text.main)
                    .lineSpacing(5.0)
                Spacer()
            }
            VStack (alignment: .leading, spacing: 20.0) {
                HStack {
                    Image(.Passkeys.iconInfo)
                        .frame(width: 24.0, height: 24.0)
                    Text("settings-passkey-disabled-header")
                        .font(.DMSans.medium.size(15.0))
                        .foregroundStyle(Color.Text.main)
                }
                Text("settings-passkeys-disabled-description")
                    .font(.DMSans.regular.size(15.0))
                    .foregroundStyle(Color.Text.gray)
                    .lineSpacing(5.0)
                SwiftUI.Button(action: { openSettingsAction() }) {
                    HStack (alignment: .center) {
                        Text("settings-passkeys-open-settings")
                            .font(.DMSans.medium.size(15.0))
                            .foregroundStyle(Color.ButtonPrimary.text)
                            .padding(.trailing, 12.0)
                        Image(.Passkeys.iconExternalLink)
                            .tint(Color.ButtonPrimary.text)
                    }
                }
                .padding(14.0)
                .frame(
                    maxWidth: .infinity
                )
                .background(Color.ButtonPrimary.bg, in: .rect(cornerRadius: 4.0))
            }
            .padding(24.0)
            .background(Color.Layer.grayLighter, in: .rect(cornerRadius: 12.0))
        }
        .padding(24.0)
    }
}
