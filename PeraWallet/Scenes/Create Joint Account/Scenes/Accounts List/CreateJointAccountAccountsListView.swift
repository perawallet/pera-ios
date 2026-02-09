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

//   CreateJointAccountAccountsListView.swift

import SwiftUI

struct CreateJointAccountAccountsListView: View {
    
    private enum NavigationOption: Hashable {
        case addAccount
        case editAccount(model: CreateJointAccountAccountsListViewModel.AccountModel)
        case selectThreshold(participantAddresses: [String])
    }
    
    // MARK: - Constants
    
    private let addAccountButtonID: String = "add_account_button_id"
    
    // MARK: - Properties
    
    private let model: CreateJointAccountAccountsListModelable
    @ObservedObject private var viewModel: CreateJointAccountAccountsListViewModel
    @Binding private var navigationPath: NavigationPath
    @State private var showCreationSheet: Bool = false
    
    // MARK: - UIKit Compatibility
    
    private var onDismissRequest: (() -> Void)?
    private var onLearnMoreTap: (() -> Void)?
    
    // MARK: - Initialiser
    
    init(model: CreateJointAccountAccountsListModelable, navigationPath: Binding<NavigationPath>, onDismissRequest: (() -> Void)?, onLearnMoreTap: (() -> Void)?) {
        self.model = model
        _navigationPath = navigationPath
        self.onDismissRequest = onDismissRequest
        self.onLearnMoreTap = onLearnMoreTap
        viewModel = model.viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            OnboardingTitleView(title: "create-joint-account-accounts-list-title", description: "create-joint-account-accounts-list-description")
            VStack(alignment: .leading) {
                Text("create-joint-account-accounts-list-message-title")
                    .font(.DMSans.medium.size(19.0))
                    .foregroundStyle(Color.Text.main)
                    .padding(.bottom, 4.0)
                Text("create-joint-account-accounts-list-message-description")
                    .font(.DMSans.regular.size(15.0))
                    .foregroundStyle(Color.Text.gray)
                    .padding(.bottom, 24.0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24.0)
            ScrollViewReader { scrollViewReader in
                List {
                    ForEach(viewModel.accounts) { model in
                        AccountRowWithEditButton(
                            image: model.image,
                            title: model.title,
                            subtitle: model.subtitle,
                            actionType: model.isEditable ? .edit : .delete,
                            onActionButtonTap: { onAccountActionButtonAction(viewModel: model) }
                        )
                        .id(model.id)
                    }
                    if viewModel.canAddAccounts {
                        SwiftUI.Button(action: onAddAccountButtonAction) {
                            HStack {
                                Image(.Icons.plus)
                                    .resizable()
                                    .frame(width: 20.0, height: 20.0)
                                Text("create-joint-account-account-list-add-button")
                                    .font(.DMSans.medium.size(15.0))
                            }
                            .foregroundStyle(Color.Helpers.positive)
                        }
                        .padding(.horizontal, 24.0)
                        .defaultPeraRowStyle()
                        .id(addAccountButtonID)
                    }
                }
                .listStyle(.plain)
                .onChange(of: viewModel.accounts.count) { _ in
                    if viewModel.canAddAccounts {
                        scrollViewReader.scrollTo(addAccountButtonID, anchor: .bottom)
                    } else {
                        scrollViewReader.scrollTo(viewModel.accounts.last?.id, anchor: .bottom)
                    }
                }
            }
            RoundedButton(contentType: .text("common-continue"), style: .primary, isEnabled: viewModel.isValidated, onTap: onContinueButtonAction)
                .padding(.horizontal, 24.0)
                .padding(.bottom, 12.0)
        }
        .navigationDestination(for: NavigationOption.self) { scene(navigationOption: $0) }
        .withPeraBackButton(navigationPath: $navigationPath)
        .background(Color.Defaults.bg)
        .onReceive(viewModel.$action) { handle(action: $0) }
        .sheet(isPresented: $showCreationSheet) {
            CreationConfirmationSheet() {
                model.updateShouldShowJointAccountCreationPopup()
                model.requestData()
            } onLearnMoreTap: {
                onLearnMoreTap?()
            }
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func scene(navigationOption: NavigationOption) -> some View {
        switch navigationOption {
        case .addAccount:
            CreateJointAccountAddAccountConstructor.buildScene(navigationPath: $navigationPath, onSelectedAddress: { model.add(account: $0) })
        case let .editAccount(viewModel):
            CreateJointAccountEditAccountConstructor.buildScene(
                name: viewModel.title,
                image: viewModel.image,
                address: viewModel.address,
                navigationPath: $navigationPath,
                onRemoveAddressButtonTap: { removeRequest(identifier: viewModel.id) },
                onDataUpdate: { model.update(identifier: viewModel.id, account: $0) }
            )
        case let .selectThreshold(participantAddresses):
            CreateJointAccountSetThresholdConstructor.buildScene(participantAddresses: participantAddresses, navigationPath: $navigationPath, onDismissRequest: onDismissRequest)
        }
    }
    
    // MARK: - Views Actions
    
    private func onAddAccountButtonAction() {
        moveTo(option: .addAccount)
    }
    
    private func onAccountActionButtonAction(viewModel: CreateJointAccountAccountsListViewModel.AccountModel) {
        guard viewModel.isEditable else {
            removeRequest(identifier: viewModel.id)
            return
        }
        moveTo(option: .editAccount(model: viewModel))
    }
    
    private func onContinueButtonAction() {
        guard model.shouldShowJointAccountCreationPopup else {
            model.requestData()
            return
        }
        
        showCreationSheet = true
    }
    
    // MARK: - Actions
    
    private func removeRequest(identifier: UUID) {
        withAnimation {
            model.remove(identifier: identifier)
        }
    }
    
    // MARK: - Handlers
    
    private func moveTo(option: NavigationOption) {
        navigationPath.append(option)
    }
    
    private func handle(action: CreateJointAccountAccountsListViewModel.Action?) {
        guard let action else { return }
        switch action {
        case let .moveNext(participantAddresses):
            moveTo(option: .selectThreshold(participantAddresses: participantAddresses))
        }
    }
}
