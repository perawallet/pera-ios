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

//   PassKeyCredentialView.swift

import SwiftUI

@available(iOS 17.0, *)
struct PassKeyCredentialView: View {
    private let mediumFont = "DMMono-Medium"
    private let regularFont = "DMMono-Medium"
    @State private(set) var viewModel: CredentialProviderViewModel
    
    init(viewModel: CredentialProviderViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack (alignment: .center, spacing: 20.0){
            if let error = viewModel.error {
                Image(.iconTrashRed)
                    .resizable()
                    .frame(width: 36.0, height: 36.0)
                
                Text(error)
                    .font(Font.custom(mediumFont, size: 19.0))
                    .foregroundStyle(Color.Text.main)
                Text("passkeys-error")
                    .font(Font.custom(regularFont, size: 15.0))
                    .foregroundStyle(Color.Text.gray)
                
                Button("title-dismiss") {
                    handleDismiss()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52.0)
                .background(Color.ButtonPrimary.bg)
                .foregroundStyle(Color.ButtonPrimary.text)
                .font(Font.custom(mediumFont, size: 15.0))
                .cornerRadius(4.0)
                
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .controlSize(.large)
                    .tint(Color.Link.primary)
                
                Text("passkeys-signing-request")
                    .foregroundStyle(Color.Text.main)
                    .font(Font.custom(mediumFont, size: 19.0))
            }
        }
        .padding(24.0)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color.Defaults.bg)
    }
    
    private func handleDismiss() {
        viewModel.dismiss()
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        PassKeyCredentialView(viewModel: CredentialProviderViewModel())
    }
}
