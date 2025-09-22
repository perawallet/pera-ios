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
    @State var showingConfirmation = false

    // MARK: - Body
    var body: some View {
        VStack(spacing: 12.0) {
            HStack (alignment: .center) {
                Image(.Settings.Icon.passkeys)
                    .resizable()
                    .foregroundStyle(Color.Text.main)
                    .frame(width: 24.0, height: 24.0)
                    .padding(.trailing, 12.0)
                
                VStack (alignment: .leading) {
                    Text(viewModel.passkey.displayName)
                        .font(.dmSans.medium.size(15.0))
                        .foregroundStyle(Color.Text.main)
                        .padding(.bottom, 2.0)
                    Text(viewModel.passkey.origin)
                        .font(.dmSans.regular.size(13.0))
                        .foregroundStyle(Color.Text.grayLighter)
                }
                .frame(
                  minWidth: 0,
                  maxWidth: .infinity,
                  minHeight: 0,
                  maxHeight: 48.0,
                  alignment: .topLeading
                )
                
                SwiftUI.Button(action: { showingConfirmation = true }) {
                    Image(.Passkeys.iconTrash)
                        .frame(width: 24.0, height: 24.0)
                }
                .padding(.leading, 12.0)
                .sheet(isPresented: $showingConfirmation) {
                    VStack(alignment: .center, spacing: 12.0) {
                        Image(.Passkeys.iconTrash)
                            .resizable()
                            .frame(width: 72, height: 72)
                            .foregroundStyle(Color.Helpers.negative)
                        
                        Text("settings-passkey-delete-title")
                            .font(.dmSans.medium.size(19.0))
                            .foregroundStyle(Color.Text.main)
                        Text("settings-passkey-delete-body")
                            .font(.dmSans.regular.size(15.0))
                            .foregroundStyle(Color.Text.gray)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 24.0)
                        
                        RoundedButton(text: "title-remove",
                                      backgroundColor: Color.ButtonPrimary.bg,
                                      textColor: Color.ButtonPrimary.text,
                                      onTap: {
                            viewModel.deletePasskey()
                        })
                        RoundedButton(text: "title-keep",
                                      backgroundColor: Color.ButtonSecondary.bg,
                                      textColor: Color.ButtonSecondary.text,
                                      onTap: {
                            showingConfirmation = false
                        })
                    }
                    .padding([.top, .leading, .trailing], 24.0)
                    .presentationDetents([.medium])
                }
            }
            
            // We use rectangles as separators because Divider wasn't rendering correctly
            Rectangle()
                .fill(Color.Layer.grayLight)
                .frame(maxWidth: .infinity, minHeight: 1.0, maxHeight: 1.0)
            
            HStack (alignment: .center) {
                Text("settings-passkeys-last-used")
                    .font(.dmSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.main)
                Spacer()
                Text(viewModel.passkey.lastUsedDisplay)
                    .font(.dmSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.grayLighter)
            }
            
            Rectangle()
                .fill(Color.Layer.grayLight)
                .frame(maxWidth: .infinity, minHeight: 1.0, maxHeight: 1.0)
            
            HStack (alignment: .center) {
                Text(String(localized: "settings-passkeys-username"))
                    .font(.dmSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.main)
                Spacer()
                Text(viewModel.passkey.username)
                    .font(.dmSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.grayLighter)
            }
        }
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.Layer.grayLight, lineWidth: 1)
        )
    }
}
