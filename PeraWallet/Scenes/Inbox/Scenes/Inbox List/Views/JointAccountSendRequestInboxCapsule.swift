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

//   JointAccountSendRequestInboxCapsule.swift

import SwiftUI

struct JointAccountSendRequestInboxCapsule: View {
    
    enum TextType {
        case raw(text: String)
        case time(date: Date)
    }
    
    // MARK: - Properties
    
    let icon: ImageResource
    let text: TextType
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 6.0) {
            Image(icon)
                .resizable()
                .frame(width: 20.0, height: 20.0)
            textView()
                .font(.DMSans.medium.size(13.0))
        }
        .foregroundStyle(Color.Text.main)
        .padding(.leading, 8.0)
        .padding(.trailing, 12.0)
        .padding(.vertical, 4.0)
        .background(Color.Layer.grayLighter)
        .cornerRadius(16.0)
    }
    
    @ViewBuilder
    private func textView() -> some View {
        switch text {
        case let .raw(text):
            Text(text)
        case let .time(date):
            Text(date, style: .relative)
        }
    }
}
