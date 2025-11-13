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

//   CreateJointAccountEditAccountView.swift

import SwiftUI

struct CreateJointAccountEditAccountView: View {

    // MARK: - Properties

    let onRemoveAddressButtonTap: () -> Void
    let onDataUpdate: (_ model: AddedAccountData) -> Void

    private let model: CreateJointAccountEditAccountModelable
    @ObservedObject private var viewModel: CreateJointAccountEditAccountViewModel
    
    @Binding var navigationPath: NavigationPath

    // MARK: - Initialisers
    
    init(model: CreateJointAccountEditAccountModelable, navigationPath: Binding<NavigationPath>, onRemoveAddressButtonTap: @escaping () -> Void, onDataUpdate: @escaping (_ model: AddedAccountData) -> Void) {
        self.model = model
        _navigationPath = navigationPath
        self.onRemoveAddressButtonTap = onRemoveAddressButtonTap
        self.onDataUpdate = onDataUpdate
        viewModel = model.viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack {
                RoundedIconView(image: viewModel.image, size: 80.0, padding: 16.0)
                    .padding(.top, 32.0)
                    .padding(.bottom, 72.0)
                LabeledUnderlinedTextField(title: "create-joint-account-edit-account-textfield-nickname-title", placeholder: "create-joint-account-edit-account-textfield-nickname-placeholder", text: $viewModel.name)
                    .padding(.horizontal, 24.0)
                    .padding(.bottom, 24.0)
                VStack(alignment: .leading) {
                    FormTitleLabel(title: "create-joint-account-edit-account-label-address-title")
                        .padding(.bottom, 2.0)
                    Text(viewModel.address)
                        .font(.DMSans.regular.size(15.0))
                        .foregroundStyle(Color.Text.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24.0)
                .padding(.bottom, 41.0)
                RoundedButton(text: "create-joint-account-button-remove", style: .destructive, isEnabled: true, onTap: onRemoveAddressButtonTapAction)
                    .padding(.horizontal, 24.0)
                Spacer()
            }
            .background(Color.Defaults.bg)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("create-joint-account-edit-account-navigation-title")
            .withPeraBackButton(navigationPath: $navigationPath)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SwiftUI.Button("common-done") { onDoneButtonTapAction() }
                        .foregroundStyle(Color.Text.main)
                }
            }
        }
        .navigationTitle("create-joint-account-edit-account-title")
        .onReceive(viewModel.$updatedModel) { model in
            guard let model else { return }
            onDataUpdate(model)
            navigationPath.removeLast()
        }
    }

    // MARK: - Actions

    private func onRemoveAddressButtonTapAction() {
        onRemoveAddressButtonTap()
        navigationPath.removeLast()
    }

    private func onDoneButtonTapAction() {
        model.updateContact()
    }
}
