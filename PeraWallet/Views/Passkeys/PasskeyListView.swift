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
import AuthenticationServices

//TODO: This is a temporary placeholder - update when we have final designs
struct PasskeyListView: View {
    
    private let model: PasskeyListModelable
    private let backHandler: () -> Void
    @ObservedObject private var viewModel: PasskeyListViewModel
    
    // MARK: - Initialisers
    
    init(onBack: @escaping () -> Void) {
        self.model = PasskeyListModel()
        self.viewModel = model.viewModel
        self.backHandler = onBack
    }
    
    // MARK: - Setups
    var body: some View {
        VStack {
            if viewModel.settingNotEnabled {
                WarningLabel().padding()
            }
            
            List {
                ForEach(viewModel.passkeys) { passkey in
                    PasskeyListCell(passkey: passkey, onDelete: passKeyDeleted)
                }
                
            }
            .overlay(Group {
                if viewModel.passkeys.isEmpty {
                    Text("settings-passkeys-empty")
                }
            })
            .scrollContentBackground(.hidden)
            .listStyle(.automatic)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(String(localized: "settings-passkeys-title"))
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading,
                content: {
                    SwiftUI.Button(action: backHandler) {
                        Image(.iconBack)
                            .foregroundStyle(Color.Text.main)
                    }
                }
            )
        }
    }
    
    private func passKeyDeleted() {
        self.viewModel.trackDeletion()
    }
}

struct WarningLabel : View {
    
    var body : some View {
        HStack {
            Image(ImageResource(name: "icon-incoming-asa-yellow-error", bundle: .main))
            Text("liquid-auth-autofill-disabled".localized())
                .foregroundColor(.Testnet.bg)
                .font(.body)
        }
        .padding()
        .border(Color.Testnet.bg, width: 1)
    }
}
