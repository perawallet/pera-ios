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

//   SheetTitleView.swift

import SwiftUI

enum SheetTitleViewAction {
    case dismiss
    case apply
}

struct SheetTitleView: View {
    
    // MARK: - Properties
    let title: LocalizedStringKey
    let onTap: (SheetTitleViewAction) -> Void
   
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.BottomSheet.line)
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 8)
            ZStack {
                HStack {
                    SwiftUI.Button(action: {
                        onTap(.dismiss)
                    }) {
                        Image(.iconClose)
                            .frame(width: 24, height: 24)
                    }
                    Spacer()
                    SwiftUI.Button("title-apply") {
                        onTap(.apply)
                    }
                    .font(.DMSans.medium.size(15))
                    .foregroundStyle(Color.Helpers.positive)
                }
                .frame(maxHeight: .infinity, alignment: .center)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.Text.main)
                    .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 44)
            .padding(.bottom, 24)
        }
    }
}
