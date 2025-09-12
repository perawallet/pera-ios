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

struct PasskeyListView: View {
    
    private let model: PasskeyListModelable
    private let onBackButtonTap: () -> Void
    @ObservedObject private var viewModel: PasskeyListViewModel
    
    // MARK: - Initialisers
    
    init(onBackButtonTap: @escaping () -> Void) {
        self.model = PasskeyListModel()
        self.viewModel = model.viewModel
        self.onBackButtonTap = onBackButtonTap
    }
    
    // MARK: - Setups
    var body: some View {
        VStack {
            if viewModel.settingNotEnabled {
                PasskeyDisabledView()
            }
            else if viewModel.passkeys.isEmpty {
                PasskeyEmptyView()
            }
            else {
                List(viewModel.passkeys) { passkey in
                    PasskeyListCell(viewModel: PasskeyListCellViewModel(passkey: passkey, onDelete: viewModel.passKeyDeleted))
                        .listRowSeparator(.hidden)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("settings-passkeys-title")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading,
                content: {
                    SwiftUI.Button(action: onBackButtonTap) {
                        Image(.iconBack)
                            .foregroundStyle(Color.Text.main)
                    }
                }
            )
        }
    }
}
