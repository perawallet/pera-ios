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
    @State var viewModel = PassKeyCredentialViewModel()
    
    var body: some View {
        VStack {
            if let error = viewModel.error {
                Text(error)
                    .font(.system(size: 16))
                    .foregroundStyle(.red)
                
                Button("Back") {
                    handleBackButtonTap()
                }
                .contentMargins([.top], 10)
                .buttonStyle(.bordered)
            } else {
                ProgressView("Signing request...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .controlSize(.large)
                    .foregroundStyle(.black)
            }
        }
        .background(Color.white)
    }
    
    private func handleBackButtonTap() {
        viewModel.error = nil
        viewModel.dismissHandler?()
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        PassKeyCredentialView()
    }
}
