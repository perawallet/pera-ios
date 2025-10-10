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

//   ConfirmSwapInfoSheet.swift

import SwiftUI

struct ConfirmSwapInfoSheet: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    var infoSheet: SwapInfoSheet

    var body: some View {
        VStack() {
            Capsule()
                .fill(Color.BottomSheet.line)
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 8)
            Spacer().frame(height: 20)
            VStack(alignment: .leading) {
                Text(infoSheet.title)
                    .font(.dmSans.medium.size(19))
                    .foregroundStyle(Color.Text.main)
                Spacer().frame(height: 20)
                Text(infoSheet.text)
                    .font(.dmSans.regular.size(15))
                    .foregroundStyle(Color.Text.main)
                Spacer()
                SwiftUI.Button {
                    dismiss()
                } label: {
                    Text("title-close")
                        .font(.dmSans.medium.size(15))
                        .foregroundStyle(Color.ButtonSecondary.text)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.ButtonSecondary.bg)
                        )
                }
                Spacer().frame(height: 20)
            }
            .padding(.horizontal, 24)

        }
        .background(Color.Defaults.bg)
        .presentationDetents([.height(infoSheet.height)])
        .presentationDragIndicator(.hidden)
    }
}

