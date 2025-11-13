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
import pera_wallet_core

struct RecoveryToolView: View {
    
    private let model: RecoveryToolModelable
    
    @ObservedObject private var viewModel: RecoveryToolViewModel
    
    // MARK: - Initialisers
    
    init(session: Session, sharedDataController: SharedDataController, hdWalletStorage: HDWalletStorable, hdWalletService: HDWalletServicing, api: ALGAPI) {
        self.model = RecoveryToolModel(session: session, sharedDataController: sharedDataController, hdWalletStorage: hdWalletStorage, hdWalletService: hdWalletService, api: api)
        self.viewModel = model.viewModel
    }
    
    // MARK: - Setups
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            Text("search-recovery-info")
                .font(.dmSans.regular.size(15.0))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.Text.main)
            Text("search-recovery-title")
                .font(.dmSans.medium.size(15.0))
                .foregroundStyle(Color.Text.main)
            TextField("search-recovery-placeholder", text: $viewModel.address)
                .font(.dmSans.medium.size(15.0))
                .foregroundStyle(Color.Text.main)
                .padding([.leading, .trailing], 5.0)
                .padding([.top, .bottom], 10.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.Layer.grayLight, lineWidth: 1)
                )
            SwiftUI.Button(
                    action: model.scanForAddress,
                    label: {
                        Text("search-recovery-button")
                            .font(.dmSans.medium.size(15.0))
                            .tint(Color.ButtonPrimary.text)
                            .padding()
                    }
                )
                .frame(height: 52.0)
                .frame(maxWidth: .infinity)
                .background(Color.ButtonPrimary.bg)
                .cornerRadius(4.0)
                .disabled(viewModel.loading)
                
            Text(viewModel.statusText)
                .font(.dmSans.regular.size(15.0))
                .multilineTextAlignment(.center)
                .foregroundStyle(viewModel.isErrorState ? Color.Helpers.negative : Color.Helpers.positive)
            
            Spacer()
        }
        .padding(20.0)
    }
}
