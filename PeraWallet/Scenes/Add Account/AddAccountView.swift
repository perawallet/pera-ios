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

//   AddAccountView.swift

import SwiftUI

struct AddAccountView: View {
    
    enum LegacyNavigationOption {
        case addAccount
        case importWallet
        case watchAccount
        case createUniversalWallet
        case createAlgo25Wallet
    }
    
    private enum NavigationOption {
        case addJointAccount
    }
    
    // MARK: - Constants
    
    private let logoWidht = 142.0
    private let logoHeight = 202.0
    private let navigationDelayTimeInterval: TimeInterval = 0.3
    
    // MARK: - Properties
    
    private let model: AddAccountModelable
    @ObservedObject var viewModel: AddAccountViewModel
    
    @State private var navigationPath = NavigationPath()
    @State private var isJointAccountOverlayVisible = false
    
    // MARK: - UIKit Compatibility
    
    var onLegacyNavigationOptionSelected: ((LegacyNavigationOption) -> Void)?
    var onDismissRequest: (() -> Void)?
    var onLearnMoreTap: (() -> Void)?
    var onScanQRTap: (() -> Void)?
    
    // MARK: - Initialisers
    
    init(model: AddAccountModelable) {
        self.model = model
        self.viewModel = model.viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            NavigationStack(path: $navigationPath) {
                ZStack(alignment: .top) {
                    VStack {
                        HStack {
                            Spacer()
                            Image(.Images.Pera.logo3D)
                                .resizable()
                                .frame(width: logoWidht, height: logoHeight)
                                .ignoresSafeArea(.all)
                        }
                        Spacer()
                    }
                    
                    Text("add-account-title")
                        .font(.DMSans.medium.size(32.0))
                        .foregroundStyle(Color.Text.main)
                        .padding(.leading, 24.0)
                        .padding(.trailing, logoWidht + 65.0)
                    
                    List {
                        ForEach(viewModel.menuRows) { option in
                            RoundedMenuRow(icon: option.icon, title: option.title, description: option.description, isNewBadgeVisible: option.isNewBadgeVisible)
                                .padding(.horizontal, 16.0)
                                .onTapGesture { handle(selectedRow: option.id) }
                        }
                        if !viewModel.isMenuExpanded {
                            AddAccountExpandListRow()
                                .padding(.top, 28.0)
                                .padding(.horizontal, 16.0)
                                .padding(.bottom, 64.0)
                                .onTapGesture(perform: onExpandMenuButtonTapAction)
                        }
                        Text(viewModel.termsAndConditionsText)
                            .font(.DMSans.regular.size(13.0))
                            .foregroundStyle(Color.Text.gray)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 48.0)
                            .padding(.horizontal, 16.0)
                            .padding(.bottom, 14.0)
                            .defaultPeraRowStyle()
                    }
                    .padding(.top, logoHeight - 50.0)
                    .listStyle(.plain)
                    .listRowSpacing(12.0)
                }
                .background(Color.Defaults.bg)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        SwiftUI.Button(action: onCloseButtonTapAction) {
                            Image(.Icons.close)
                                .resizable()
                                .frame(width: 24.0, height: 24.0)
                                .foregroundStyle(Color.Text.main)
                        }
                    }
                }
                .navigationDestination(for: NavigationOption.self) {
                    switch $0 {
                    case .addJointAccount:
                        CreateJointAccountAccountsListConstructor.buildScene(
                            navigationPath: $navigationPath,
                            model: model.sharedJointAccountModel,
                            scannedAddress: $viewModel.scannedAddress,
                            onDismissRequest: onDismissRequest,
                            onLearnMoreTap: onLearnMoreTap,
                            onScanQRTap: onScanQRTap
                        )
                    }
                }
                .onAppear { model.sharedJointAccountModel.reset() }
            }
            
            CreateJointAccountOverlay(isVisible: $isJointAccountOverlayVisible) {
                onJointAccountContinueButtonTapAction()
            }
        }
    }
    
    // MARK: - Actions
    
    private func onJointAccountContinueButtonTapAction() {
        isJointAccountOverlayVisible = false
        DispatchQueue.main.asyncAfter(deadline: .now() + navigationDelayTimeInterval) {
            moveTo(option: .addJointAccount)
        }
    }
    
    private func onExpandMenuButtonTapAction() {
        withAnimation {
            viewModel.isMenuExpanded = true
        }
    }
    
    private func onCloseButtonTapAction() {
        onDismissRequest?()
    }
    
    // MARK: - Handlers
    
    private func handle(selectedRow: AddAccountViewModel.RowIdentifier) {
        switch selectedRow {
        case .addAccount:
            moveTo(option: .addAccount)
        case .addJointAccount:
            isJointAccountOverlayVisible = true
        case .importWallet:
            moveTo(option: .importWallet)
        case .watchAccount:
            moveTo(option: .watchAccount)
        case .createUniversalWallet:
            moveTo(option: .createUniversalWallet)
        case .createAlgo25Wallet:
            moveTo(option: .createAlgo25Wallet)
        }
    }
    
    // MARK: - Navigation
    
    private func moveTo(option: NavigationOption) {
        navigationPath.append(option)
    }
    
    private func moveTo(option: LegacyNavigationOption) {
        onLegacyNavigationOptionSelected?(option)
    }
}
