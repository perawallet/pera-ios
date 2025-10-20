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

//   OnboardingTitleView.swift

import SwiftUI

struct OnboardingTitleView: View {
    
    // MARK: - Properties
    
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.DMSans.medium.size(32.0))
                    .foregroundStyle(Color.Text.main)
                    .padding(.bottom, 10.0)
                Text(description)
                    .font(.DMSans.regular.size(15.0))
                    .foregroundStyle(Color.Text.gray)
                    .padding(.bottom, 32.0)
            }
            .padding(.horizontal, 24.0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
