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

//   ConfirmSwapView.swift

import SwiftUI

struct ConfirmSwapView: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    var account: AccountInformation

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    SwiftUI.Button(action: {
                        dismiss()
                    }) {
                        Image("icon-close")
                            .frame(width: 24, height: 24)
                    }
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, 24)
                VStack {
                    Text("swap-confirm-title")
                        .font(.dmSans.medium.size(15))
                        .foregroundStyle(Color.Text.main)
                    Spacer().frame(height: 2)
                    HStack {
                        Image(account.hdWalletAddressDetail != nil ? "icon-hd-account" : "icon-standard-account")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Spacer().frame(width: 6)
                        Text(account.name)
                            .font(.dmSans.regular.size(13))
                            .foregroundStyle(Color.Text.gray)
                    }
                }
            }
            .frame(height: 60)
            .padding(.top, 8)
            .padding(.bottom, 30)
            ConfirmSwapAssetView(assetIcon: Image("icon-algo-circle"), assetText: "ALGO", primaryBalanceText: "2,000.00", secondaryBalanceText: "$600.08", showTrustedIcon: true)
            
            HStack {
                Rectangle()
                    .fill(Color.Layer.grayLighter)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                Text("title-to")
                    .font(.dmSans.medium.size(11))
                    .foregroundStyle(Color.Text.grayLighter)
                    .padding(.horizontal, 14)
                Rectangle()
                    .fill(Color.Layer.grayLighter)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 16)
            .padding(.vertical, 4)
            ConfirmSwapAssetView(assetIcon: Image("icon-algo-circle"), assetText: "USDC", primaryBalanceText: "600.08", secondaryBalanceText: "$600.08", showTrustedIcon: false)
            Rectangle()
                .fill(Color.Layer.grayLighter)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            VStack {
                HStack {
                   Text("title-price")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    Text("0.17809 ALGO per AKTA")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.top, 28)
                .padding(.bottom, 16)
                HStack {
                   Text("title-provider")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    Text("Vestige")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 16)
                HStack {
                   Text("swap-slippage-title")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    Text("0.5%")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 16)
                HStack {
                   Text("swap-price-impact-title")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    Text("0.306%")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 16)
                HStack {
                   Text("swap-confirm-minimum-received-title")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    Text("1,365,310.296595 AKTA")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 16)
                HStack {
                   Text("title-exchange-fee")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    Text("0.219412")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 16)
                HStack {
                   Text("swap-confirm-pera-fee-title")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.gray)
                    Spacer()
                    Text("0.149382")
                        .font(.dmSans.regular.size(13))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            ConfirmSlideButton() {
                print("confirmed!")
            }
                .padding(.horizontal, 24)
            Spacer()
        }
        .background(Color.Defaults.bg)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}

private struct ConfirmSwapAssetView: View {
    // MARK: - Properties
    var assetIcon: Image
    var assetText: String
    var primaryBalanceText: String
    var secondaryBalanceText: String
    var showTrustedIcon: Bool
    
    // MARK: - Body
    var body: some View {
        HStack (alignment: .center) {
            assetIcon
                .resizable()
                .frame(width: 40, height: 40)
            Spacer().frame(width: 16)
            VStack (alignment: .leading) {
                Text(primaryBalanceText)
                    .font(.dmSans.medium.size(18))
                    .foregroundStyle(Color.Text.main)
                Text(secondaryBalanceText)
                    .font(.dmSans.regular.size(13))
                    .foregroundStyle(Color.Text.grayLighter)
            }
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.Layer.grayLightest)
                HStack {
                    Text(assetText)
                        .font(.dmSans.regular.size(15))
                        .foregroundStyle(Color.Text.main)
                    Spacer().frame(width: 6)
                    Image(showTrustedIcon ? "icon-trusted" : "icon-verified")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                .padding(.horizontal, 16)
            }
            .frame(width: 94, height: 48)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 105)
    }
}
