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

//   RecoveredAccountsListView.swift

import SwiftUI

struct RecoveredAccountsListView: View {
    
    // MARK: - Properties
    
    @ObservedObject private var model: RecoveredAccountsListModel
    
    // MARK: - UIKit Compatibility
    
    var dismiss: ((_ isSuccess: Bool) -> Void)?
    var openDetails: ((_ account: Account, _ authAccount: Account) -> Void)?
    
    // MARK: - Initialisers
    
    init(model: RecoveredAccountsListModel) {
        self.model = model
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0.0) {
            HStack {
                Image("icon-wallet")
                    .resizable()
                    .frame(width: 48.0, height: 48.0)
                Spacer()
            }
            .padding(.top, 32.0)
            .padding(.bottom, 24.0)
            Text("rekeyed-account-selection-list-header-title".localized(model.addressViewModels.count))
                .foregroundStyle(Color(uiColor: Colors.Text.main.uiColor)) // FIXME: Replace Color with Color from assets catalogue.
                .font(.dmSans.medium.size(19.0))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12.0)
            Text("rekeyed-account-selection-list-header-body".localized(model.addressViewModels.count))
                .foregroundStyle(Color(uiColor: Colors.Text.gray.uiColor)) // FIXME: Replace Color with Color from assets catalogue.
                .font(.dmSans.regular.size(15.0))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 40.0)
            SwiftUI.ScrollView {
                ForEach(model.addressViewModels) { viewModel in
                    RecoveredAccountsListCell(
                        isSelected: viewModel.isSelected,
                        accountTypeName: viewModel.accountTypeImageName,
                        title: viewModel.displayedAddress,
                        subtitle: viewModel.description,
                        onTickAction: { model.toggleSelection(address: viewModel.address) },
                        onInfoButtonAction: { model.requestDetails(address: viewModel.address) }
                    )
                }
            }
            .padding(.bottom, 12.0)
            if !model.addressViewModels.isEmpty {
                FormButton(text: "rekeyed-account-selection-list-primary-action-title", style: model.isAddressSelected ? .primary : .disabled) { model.confirmSelection() }
                    .padding(.bottom, 12.0)
            }
            FormButton(text: model.addressViewModels.isEmpty ? "title-continue" : "rekeyed-account-selection-list-secondary-action-title", style: .secondary) { dismiss?(false) }
                .padding(.bottom, 16.0)
            
        }
        .padding(.horizontal, 24.0)
        .background(Color(uiColor: Colors.Defaults.background.uiColor)) // FIXME: Replace Color with Color from assets catalogue.
        .onReceive(model.$action) { handle(action: $0) }
    }
    
    // MARK: Handlers
    
    private func handle(action: RecoveredAccountsListModel.Action?) {
        
        guard let action else { return }
        
        switch action {
        case .endWithSuccess:
            dismiss?(true)
        case let .showDetails(account, authAccount):
            openDetails?(account, authAccount)
        }
    }
}

// FIXME: Add Preview
