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

//   RemoteConfigListCell.swift

import SwiftUI
import pera_wallet_core

struct RemoteConfigListCell: View {
    let item: FeatureFlag
    let remoteConfigValue: Bool
    @State private var isOverridden: Bool = false
    @State private var overrideValue: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            SwiftUI.Toggle(isOn: $isOverridden) {
                HStack {
                    VStack (alignment: .leading) {
                        Text(item.title)
                            .font(.DMSans.bold.size(15))
                            .foregroundStyle(Color.Text.main)
                        Text(remoteConfigValue ? "feature-flag-enabled-text".localized(item.rawValue) : "feature-flag-disabled-text".localized(item.rawValue))
                            .font(.DMSans.regular.size(13))
                            .foregroundStyle(Color.Text.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(height: 50)
            }
            .onChange(of: isOverridden) { newValue in
                if newValue {
                    overrideValue = remoteConfigValue
                    RemoteConfigOverride.set(overrideValue, for: item.rawValue)
                } else {
                    RemoteConfigOverride.remove(for: item.rawValue)
                }
            }
            
            if isOverridden {
                SwiftUI.Toggle(isOn: $overrideValue) {
                    HStack {
                        Text(overrideValue ? "overridden-enabled-text" : "overridden-disabled-text")
                            .font(.DMSans.regular.size(13))
                            .foregroundStyle(Color.Text.main)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 50)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                .onChange(of: overrideValue) { _ in
                    RemoteConfigOverride.set($overrideValue.wrappedValue, for: item.rawValue)
                }
            }
        }
        .animation(.easeInOut, value: isOverridden)
        .onAppear {
            isOverridden = RemoteConfigOverride.isEnabled(for: item.rawValue)
            if isOverridden {
                overrideValue = RemoteConfigOverride.value(for: item.rawValue) ?? false
            }
        }
    }
}
