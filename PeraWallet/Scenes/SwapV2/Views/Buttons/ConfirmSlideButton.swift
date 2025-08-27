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

//   ConfirmSlideButton.swift

import SwiftUI

struct ConfirmSlideButton: View {
    var onConfirm: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isConfirmed = false

    private let buttonHeight: CGFloat = 52
    private let circleSize: CGFloat = 44

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.Layer.grayLighter)
                    .frame(height: buttonHeight)

                Text(isConfirmed ? "title-confirmed" : "title-slide-to-confirm")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)

                Circle()
                    .fill(isConfirmed ? Color.Helpers.success : Color.ButtonPrimary.bg)
                    .frame(width: circleSize, height: circleSize)
                    .overlay(
                        Image(isConfirmed ? "icon-success-24" : "icon-arrow-24")
                            .renderingMode(isConfirmed ? .original : .template)
                            .foregroundColor(isConfirmed ? nil : Color.Defaults.bg)
                    )
                    .offset(x: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isConfirmed {
                                    dragOffset = min(max(0, value.translation.width), geometry.size.width - circleSize - 4)
                                }
                            }
                            .onEnded { _ in
                                if dragOffset > geometry.size.width * 0.6 {
                                    dragOffset = geometry.size.width - circleSize - 4
                                    isConfirmed = true
                                    onConfirm()
                                } else {
                                    dragOffset = 0
                                }
                            }
                    )
                    .padding(.leading, 4)
            }
            .frame(height: buttonHeight)
            .frame(maxWidth: .infinity)
            .animation(.easeInOut(duration: 0.2), value: dragOffset)
        }
        .frame(height: buttonHeight)
    }
}
