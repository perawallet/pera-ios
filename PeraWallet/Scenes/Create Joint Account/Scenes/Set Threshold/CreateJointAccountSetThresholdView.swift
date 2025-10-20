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

//   CreateJointAccountSetThresholdView.swift

import SwiftUI

struct CreateJointAccountSetThresholdView: View {
    
    private enum NavigationOption: Hashable {
        case nameAccount(participantAddresses: [String], threshold: Int)
    }
    
    // MARK: - Properties
    
    private let model: CreateJointAccountSetThresholdModelable
    @ObservedObject var viewModel: CreateJointAccountSetThresholdViewModel
    @Binding private var navigationPath: NavigationPath
    
    // MARK: - UIKit Compatibility
    
    private var onDismissRequest: (() -> Void)?
    
    // MARK: - Initialisers
    
    init(model: CreateJointAccountSetThresholdModelable, navigationPath: Binding<NavigationPath>, onDismissRequest: (() -> Void)?) {
        self.model = model
        self._navigationPath = navigationPath
        self.onDismissRequest = onDismissRequest
        viewModel = model.viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            OnboardingTitleView(title: "create-joint-account-threshold-title", description: "create-joint-account-threshold-description")
            Grid(alignment: .leading) {
                GridRow {
                    VStack(alignment: .leading) {
                        Text("create-joint-account-threshold-label-number-of-accounts-title")
                            .font(.DMSans.regular.size(15.0))
                            .foregroundStyle(Color.Text.main)
                            .lineLimit(1)
                        Text("create-joint-account-threshold-label-number-of-accounts-description")
                            .font(.DMSans.regular.size(13.0))
                            .foregroundStyle(Color.Text.gray)
                            .lineLimit(1)
                    }
                    .layoutPriority(1.0)
                    Spacer()
                        .frame(maxHeight: 1.0)
                    HStack {
                        Image(.Icons.group)
                            .resizable()
                            .frame(width: 32.0, height: 32.0)
                            .foregroundStyle(Color.Text.grayLighter)
                            .padding(.trailing, 16.0)
                        Text(String(viewModel.numberOfAccounts))
                            .font(.DMSans.medium.size(28.0))
                            .foregroundStyle(Color.Text.grayLighter)
                    }
                    .layoutPriority(0.0)
                }
                GridRow {
                    Text("create-joint-account-threshold-label-threshold-title")
                        .font(.DMSans.regular.size(15.0))
                        .foregroundStyle(Color.Text.main)
                        .layoutPriority(1.0)
                    Spacer()
                        .frame(maxHeight: 1.0)
                    CounterView(minValue: 1, maxValue: viewModel.numberOfAccounts, value: $viewModel.threshold)
                        .layoutPriority(0.0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24.0)
            Spacer()
            RoundedButton(text: "common-continue", style: .primary, isEnabled: true, onTap: onContinueButtonAction)
                .padding(.horizontal, 24.0)
                .padding(.bottom, 12.0)
                .navigationDestination(for: NavigationOption.self) { scene(navigationOption: $0) }
                .onReceive(viewModel.$action) { handle(action: $0) }
        }
        .background(Color.Defaults.bg)
        .withPeraBackButton(navigationPath: $navigationPath)
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func scene(navigationOption: NavigationOption) -> some View {
        switch navigationOption {
        case let .nameAccount(participantAddresses, threshold):
            CreateJointAccountNameAccountConstructor.buildScene(participantAddresses: participantAddresses, threshold: threshold, navigationPath: $navigationPath, onDismissRequest: onDismissRequest)
        }
    }
    
    // MARK: - Actions
    
    private func onContinueButtonAction() {
        model.requestData()
    }
    
    // MARK: - Handlers
    
    private func handle(action: CreateJointAccountSetThresholdViewModel.Action?) {
        guard let action else { return }
        switch action {
        case let .moveNext(participantAddresses, threshold):
            navigationPath.append(NavigationOption.nameAccount(participantAddresses: participantAddresses, threshold: threshold))
        }
    }
}
