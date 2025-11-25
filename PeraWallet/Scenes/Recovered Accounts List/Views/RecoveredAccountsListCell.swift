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

//   RecoveredAccountsListCell.swift

import SwiftUI

struct RecoveredAccountsListCell: View {
    
    // MARK: - Properties
    
    var isSelected: Bool
    var accountTypeName: String
    var title: any StringProtocol
    var subtitle: any StringProtocol
    var onTickAction: () -> Void
    var onInfoButtonAction: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 16.0) {
            Checkbox(isOn: isSelected, onValueChange: onTickAction)
                .padding(.leading, 16.0)
            Image(accountTypeName)
                .resizable()
                .frame(width: 40.0, height: 40.0)
            VStack(alignment: .leading, spacing: 0.0) {
                Text(title)
                    .foregroundStyle(Color(uiColor: Colors.Text.main.uiColor)) // FIXME: Replace Color with Color from assets catalogue.
                    .font(.DMSans.regular.size(15.0))
                Text(subtitle)
                    .foregroundStyle(Color(uiColor: Colors.Text.grayLighter.uiColor)) // FIXME: Replace Color with Color from assets catalogue.
                    .font(.DMSans.regular.size(13.0))
            }
            Spacer()
            SwiftUI.Button(action: onInfoButtonAction) {
                Image(.iconInfoGray)
                    .resizable()
                    .frame(width: 24.0, height: 24.0)
            }
            .padding(.trailing, 16.0)
        }
        .padding(.vertical, 16.0)
        .background(
            Color(uiColor: Colors.Defaults.background.uiColor) // FIXME: Replace Color with Color from assets catalogue.
                .cornerRadius(12.0)
                .defaultShadow()
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12.0)
                .stroke(Color(uiColor: Colors.Helpers.success.uiColor), lineWidth: 2.0) // FIXME: Replace Color with Color from assets catalogue.
                .opacity(isSelected ? 1.0 : 0.0)
                .padding(2.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        )
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }
}

#Preview {
    RecoveredAccountsListCell(isSelected: true, accountTypeName: "", title: "-= Title =-", subtitle: "-= Subtitle =-", onTickAction: {}, onInfoButtonAction: {})
}
