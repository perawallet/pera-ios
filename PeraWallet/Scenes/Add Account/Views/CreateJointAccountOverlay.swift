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

//   CreateJointAccountOverlay.swift

import SwiftUI

struct CreateJointAccountOverlay: View {
    
    // MARK: - Properties
    
    @Binding var isVisible: Bool
    var onButtonTap: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isVisible {
                Color.Backdrop.modalBg
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            if isVisible {
                VStack {
                    Image(.Images.JointAccount.Create.Overlay.header)
                    Text("common-badge-new")
                        .font(.DMSans.bold.size(11.0))
                        .foregroundStyle(Color.Helpers.positive)
                        .padding(.vertical, 1.0)
                        .padding(.horizontal, 5.0)
                        .background(Color.Helpers.positiveLighter)
                        .cornerRadius(8.0)
                    Text("add-account-joint-account-overlay-title")
                        .font(.DMSans.medium.size(19.0))
                        .foregroundStyle(Color.Text.main)
                        .padding(.top, 8.0)
                    VStack {
                        CreateJointAccountOverlayListRow(index: 1, text: "add-account-joint-account-overlay-list-description-1")
                            .padding(.top, 12.0)
                        CreateJointAccountOverlayListRow(index: 2, text: "add-account-joint-account-overlay-list-description-2")
                            .padding(.top, 12.0)
                        CreateJointAccountOverlayListRow(index: 3, text: "add-account-joint-account-overlay-list-description-3")
                            .padding(.top, 12.0)
                    }
                    .padding(.horizontal, 24.0)
                    RoundedButton(contentType: .text("common-continue"), style: .primary, isEnabled: true, onTap: onButtonTap)
                        .padding(.all, 32.0)
                }
                .background(Color.Defaults.bg)
                .cornerRadius(16.0)
                .padding(24.0)
                .transition(.moveFromPointToCenter(point: CGPoint(x: 0.0, y: 80.0)).combined(with: .opacity))
                .zIndex(1.0)
            } else {
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
}

private struct CreateJointAccountOverlayListRow: View {
    
    // MARK: - Properties
    
    let index: Int
    let text: LocalizedStringKey
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top, spacing: 16.0) {
            Text(String(index))
                .frame(width: 32.0, height: 32.0)
                .background(Color.Defaults.bg)
                .cornerRadius(16.0)
                .defaultShadow()
            Text(text)
                .padding(.top, 6.0)
        }
        .font(.DMSans.regular.size(15.0))
        .foregroundStyle(Color.Text.gray)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
