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
    var accountIcon: Image
    var accountText: String

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
                        accountIcon
                            .resizable()
                            .frame(width: 16, height: 16)
                        Spacer().frame(width: 6)
                        Text(accountText)
                            .font(.dmSans.regular.size(13))
                            .foregroundStyle(Color.Text.gray)
                    }
                }
            }
            .frame(height: 60)
            .padding(.top, 8)
            .padding(.bottom, 24)

            Spacer()
        }
        .background(Color.Defaults.bg)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}
