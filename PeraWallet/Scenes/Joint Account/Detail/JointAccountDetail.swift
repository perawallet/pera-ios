// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   JointAccountDetail.swift

import SwiftUI

struct JointAccountDetail: View {
    
    // MARK: - Properties
    
    private let model: JointAccountDetailModelable
    @ObservedObject private var viewModel: JointAccountDetailViewModel
    
    // MARK: - Properties - UIKit Compatibility
    
    var onCopyAddressAction: ((_ address: String) -> Void)?
    
    // MARK: - Initializers
    
    init(model: JointAccountDetailModelable) {
        self.model = model
        viewModel = model.viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Grid(verticalSpacing: 16.0) {
                GridRow(alignment: .top) {
                    summaryLabels(title: "joint-account-invite-confirmation-overlay-summary-number-of-accounts-title", message: "joint-account-invite-confirmation-overlay-summary-number-of-accounts-message")
                    Image(.Icons.group)
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                        .foregroundStyle(Color.Text.grayLighter)
                        .padding(.trailing, 16.0)
                    Text(verbatim: "\(viewModel.addressCount)")
                        .font(.DMSans.medium.size(28.0))
                        .foregroundStyle(Color.Text.grayLighter)
                }
                GridRow(alignment: .top) {
                    summaryLabels(title: "joint-account-invite-confirmation-overlay-summary-threshold-title", message: "joint-account-invite-confirmation-overlay-summary-threshold-message")
                    Spacer()
                        .frame(width: 32.0, height: 32.0)
                    Text(verbatim: "\(viewModel.threshold)")
                        .font(.DMSans.medium.size(28.0))
                        .foregroundStyle(Color.Text.main)
                }
            }
            .padding(.horizontal, 16.0)
            .padding(.vertical, 12.0)
            .background(Color.Layer.grayLighter)
            .cornerRadius(16.0)
            .padding(.horizontal, 23.0)
            .padding(.top, 24.0)
            HStack {
                Text("joint-account-invite-confirmation-overlay-list-section-title-\(viewModel.addressCount)")
                    .font(.DMSans.medium.size(15.0))
                    .foregroundStyle(Color.Text.main)
                Spacer()
            }
            .padding(.top, 32.0)
            .padding(.horizontal, 16.0)
            ScrollView {
                VStack {
                    ForEach(viewModel.accountModels) { accountModel in
                        JointAccountInviteConfirmationOverlayAccountRow(
                            image: accountModel.image,
                            title: accountModel.title,
                            subtitle: accountModel.subtitle,
                            showDivider: viewModel.accountModels.last?.id != accountModel.id,
                            onCopyAction: { onCopyAction(address: accountModel.id) }
                        )
                    }
                }
            }
        }
        .background(Color.Defaults.bg)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(viewModel.title)
                        .font(.DMSans.medium.size(15.0))
                        .foregroundStyle(Color.Text.main)
                    if let subtitle = viewModel.subtitle {
                        Text(subtitle)
                            .font(.DMSans.regular.size(13.0))
                            .foregroundStyle(Color.Text.gray)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func summaryLabels(title: LocalizedStringKey, message: LocalizedStringKey) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.DMSans.regular.size(15.0))
                    .foregroundStyle(Color.Text.main)
                    .fixedSize(horizontal: false, vertical: true)
                Text(message)
                    .font(.DMSans.regular.size(13.0))
                    .foregroundStyle(Color.Text.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    private func onCopyAction(address: String) {
        onCopyAddressAction?(address)
    }
}
