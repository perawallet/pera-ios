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

//   CreationConfirmationSheet.swift

import SwiftUI

struct CreationConfirmationSheet: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    var onConfirmTap: () -> Void
    var onLearnMoreTap: () -> Void

    var body: some View {
        VStack() {
            Capsule()
                .fill(Color.BottomSheet.line)
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 8)
            Spacer().frame(height: 20)
            VStack(alignment: .center) {
                Image(.iconInfoBlack24)
                    .resizable()
                    .frame(width: 72, height: 72)
                    .padding(.bottom, 20)
                Text("joint-account-confirmation-sheet-title")
                    .font(.DMSans.medium.size(19))
                    .foregroundStyle(Color.Text.main)
                    .padding(.bottom, 40)
                HStack {
                    ZStack {
                        Image(.bgImportAccountInstruction)
                            .resizable()
                            .scaledToFit()
                        Text(verbatim: "1")
                            .font(.DMSans.regular.size(15))
                            .foregroundStyle(Color.Text.gray)
                    }
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 20)
                    Text("joint-account-confirmation-sheet-first-text")
                        .font(.DMSans.regular.size(15))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 24)
                HStack {
                    ZStack {
                        Image(.bgImportAccountInstruction)
                            .resizable()
                            .scaledToFit()
                        Text(verbatim: "2")
                            .font(.DMSans.regular.size(15))
                            .foregroundStyle(Color.Text.gray)
                    }
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 20)
                    Text("joint-account-confirmation-sheet-second-text")
                        .font(.DMSans.regular.size(15))
                        .foregroundStyle(Color.Text.main)
                }
                .padding(.bottom, 24)
                HStack {
                    Image(.iconInfoPositive)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 4)
                    Text("title-learn-more")
                        .font(.DMSans.medium.size(15))
                        .foregroundStyle(Color.Helpers.positive)
                }
                .padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture { onLearnMoreTap() }
                Spacer()
                SwiftUI.Button {
                    onConfirmTap()
                    dismiss()
                } label: {
                    Text("title-proceed")
                        .font(.DMSans.medium.size(15))
                        .foregroundStyle(Color.ButtonPrimary.text)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.ButtonPrimary.bg)
                        )
                }
                .padding(.bottom, 12)
                SwiftUI.Button {
                    dismiss()
                } label: {
                    Text("joint-account-confirmation-sheet-dismiss-button-text")
                        .font(.DMSans.medium.size(15))
                        .foregroundStyle(Color.ButtonSecondary.text)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.ButtonSecondary.bg)
                        )
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)

        }
        .background(Color.Defaults.bg)
        .presentationDetents([.height(600)])
        .presentationDragIndicator(.hidden)
    }
}

