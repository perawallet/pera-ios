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

//   JointAccountPendingTransactionOverlayRow.swift

import SwiftUI

struct JointAccountPendingTransactionOverlayRow: View {
    
    enum State {
        case approved
        case rejected
        case unknown
    }
    
    // MARK: - Properties
    
    let avatar: ImageType
    let title: String
    let subtitle: String?
    let state: State
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 8.0) {
            RoundedIconView(image: avatar, size: 20.0, padding: 4.0)
                .padding(.leading, 12.0)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.DMSans.regular.size(15.0))
                    .foregroundStyle(state == .rejected ? Color.Helpers.negative : Color.Text.main)
                if let subtitle {
                    Text(subtitle)
                        .font(.DMSans.regular.size(13.0))
                        .foregroundStyle(Color.Text.grayLighter)
                }
            }
            Spacer()
            stateIcon()
                .frame(width: 20.0, height: 20.0)
                .padding(.trailing, 12.0)
                
        }
        .frame(height: 60.0)
        .overlay {
            RoundedRectangle(cornerRadius: 12.0)
                .stroke(Color.Layer.gray, lineWidth: 1.0)
        }
    }
    
    @ViewBuilder
    private func stateIcon() -> some View {
        switch state {
        case .approved:
            Image(.Icons.check)
                .resizable()
                .foregroundStyle(Color.Helpers.positive)
        case .rejected:
            Image(.Icons.close)
                .resizable()
                .foregroundStyle(Color.Helpers.negative)
        case .unknown:
            ProgressView()
                .tint(.Text.gray)
        }
    }
}
