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

//   InboxJointAccountCoreRow.swift

import SwiftUI

struct InboxJointAccountCoreRow<Content: View>: View {
    
    // MARK: - Constants
    
    private let dotSize = 4.0
    private let topSectionHeight = 40.0
    
    // MARK: - Properties
    
    let isDotVisible: Bool
    let message: AttributedString
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack(spacing: 12.0) {
            VStack {
                HStack(spacing: 0.0) {
                    if isDotVisible {
                        Circle()
                            .frame(width: dotSize, height: dotSize)
                            .foregroundStyle(Color.Link.icon)
                    }
                    RoundedIconView(
                        image: .icon(
                            data: ImageType.IconData(
                                image: .Icons.group,
                                tintColor: .Wallet.wallet1,
                                backgroundColor: .Wallet.wallet1Icon
                            )
                        ),
                        size: topSectionHeight,
                        padding: 8.0
                    )
                    .padding(.leading, 8.0 + (isDotVisible ? 0.0 : dotSize))
                }
                Spacer()
            }
            VStack(spacing: 12.0) {
                HStack {
                    Text(message)
                        .font(.DMSans.medium.size(15.0))
                        .foregroundStyle(Color.Text.main)
                    Spacer()
                }
                .frame(minHeight: topSectionHeight)
                content
            }
        }
        .padding(.top, 16.0)
        .padding(.horizontal, 12.0)
        .frame(maxWidth: .infinity)
    }
}
