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

//   ChartSegmentedControlView.swift

import SwiftUI

struct ChartSegmentedControlView: View {
    @Binding var selected: ChartDataPeriod

    var body: some View {
        HStack(spacing: 16) {
            ForEach(ChartDataPeriod.allCases, id: \.self) { segment in
                Text(segment.title)
                    .font(Typography.bodyMedium().font)
                    .foregroundColor(selected == segment ? Color("Text/main") : Color("Text/grayLighter"))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selected == segment ? Color("ButtonGhost/focusBg") : Color.clear)
                    )
                    .onTapGesture {
                        selected = segment
                    }
            }
        }
    }
}

