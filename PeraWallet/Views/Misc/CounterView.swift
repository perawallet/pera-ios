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

//   CounterView.swift

import SwiftUI

struct CounterView: View {
    
    // MARK: - Properties
    
    let minValue: Int
    let maxValue: Int
    @Binding var value: Int
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            SquareIconButton(icon: .Icons.minus, isEnabled: value > minValue) { value -= 1 }
            Spacer()
            if value < 100 {
                valueText(value: value)
            }
            else {
                valueText(value: value)
                    .minimumScaleFactor(0.5)
            }
            Spacer()
            SquareIconButton(icon: .Icons.plus, isEnabled: value < maxValue) { value += 1 }
        }
        .frame(width: 137.0)
    }
    
    @ViewBuilder
    private func valueText(value: Int) -> some View {
        Text(String(value))
            .font(.DMSans.medium.size(28.0))
            .lineLimit(1)
    }
}
