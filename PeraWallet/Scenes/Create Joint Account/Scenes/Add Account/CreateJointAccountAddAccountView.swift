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

//   CreateJointAccountAddAccountView.swift

import SwiftUI

struct CreateJointAccountAddAccountView: View {

    // MARK: - Properties

    var onSelectedAddress: (AddedAccountData) -> Void

    private let model: CreateJointAccountAddAccountModelable
    @ObservedObject private var viewModel: CreateJointAccountAddAccountViewModel
    @Binding private var navigationPath: NavigationPath

    // MARK: - Initialisers

    init(model: CreateJointAccountAddAccountModelable, navigationPath: Binding<NavigationPath>, onSelectedAddress: @escaping (AddedAccountData) -> Void) {
        self.model = model
        _navigationPath = navigationPath
        self.onSelectedAddress = onSelectedAddress
        viewModel = model.viewModel
    }
    
    // MARK: - Body

    var body: some View {
        VStack {
            SearchFieldWithPasteButton(
                placeholder:
                    "create-joint-account-add-account-search-field-placeholder",
                text: $viewModel.searchText
            ) { model.pasteFromClipboard() }
            .textInputAutocapitalization(.never)
            .padding(.horizontal, 24.0)
            .padding(.top, 20.0)
            .padding(.bottom, 32.0)
            if viewModel.accountsListSections.isEmpty {
                VStack {
                    Text("create-joint-account-add-account-list-placeholder")
                        .font(.DMSans.regular.size(15.0))
                        .foregroundStyle(Color.Text.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 24.0)
                    Spacer()
                }
            } else {
                List(viewModel.accountsListSections) { section in
                    if let sectionTitle = section.title {
                        Section(header: TitleSectionHeader(title: sectionTitle))
                        {
                            accountsList(rows: section.rows)
                        }
                    } else {
                        accountsList(rows: section.rows)
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(Color.Defaults.bg)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("create-joint-account-add-account-navigation-title")
        .withPeraBackButton(navigationPath: $navigationPath)
        .onReceive(viewModel.$selectedAccount) { handle(selectedAccount: $0) }
    }

    @ViewBuilder
    private func accountsList(
        rows: [CreateJointAccountAddAccountViewModel.AccountRowType]
    ) -> some View {
        ForEach(rows, id: \.self) {
            switch $0 {
            case let .normal(accountModel):
                AccountRowWithValues(
                    image: accountModel.image,
                    title: accountModel.title,
                    subtitle: accountModel.subtitle,
                    primaryValue: accountModel.primaryValue,
                    secondaryValue: accountModel.secondaryValue
                )
                .onTapGesture { model.select(normalAccount: accountModel) }
            case let .add(accountModel):
                AccountRowWithAddButton(
                    image: .icon(
                        data: ImageType.IconData(
                            image: .Icons.user, tintColor: .Wallet.wallet1,
                            backgroundColor: .Wallet.wallet1Icon)),
                    title: accountModel.title,
                    subtitle: accountModel.subtitle,
                    onAddButtonTap: {
                        model.select(specialAccount: accountModel)
                    }
                )
            }
        }
    }

    // MARK: - Handlers

    private func handle(selectedAccount: AddedAccountData?) {
        guard let selectedAccount else { return }
        onSelectedAddress(selectedAccount)
        navigationPath.removeLast()
    }
}
