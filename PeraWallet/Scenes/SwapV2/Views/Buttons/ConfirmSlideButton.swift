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
    @State private var dragOffset: CGFloat = 0
    @Binding var state: ConfirmSlideButtonState
    var isSwapDisabled: Bool
    var onConfirm: () -> Void

    private let buttonHeight: CGFloat = 44
    private let circleSize: CGFloat = 52

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color.Layer.grayLighter)
                    .frame(height: buttonHeight)
                
                Rectangle()
                    .fill(state.buttonBackgroundColor)
                    .frame(
                        width: state == .idle ? (dragOffset > 0 ? dragOffset + circleSize / 2 : 0) : geometry.size.width,
                        height: buttonHeight
                    )
                    .mask(
                        RoundedCorner(radius: 26, corners: state == .idle ? [.topLeft, .bottomLeft] : [.allCorners])
                    )
                
                if let iconName = state.iconName {
                    Image(iconName)
                        .resizable()
                        .renderingMode(state == .success || state == .error ? .template : .original)
                        .frame(width: 24, height: 24)
                        .foregroundColor(state == .success || state == .error ? Color.Text.white : nil)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    if state == .idle {
                        Text("title-slide-to-confirm")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isSwapDisabled ? Color.ButtonPrimary.disabledText : Color.ButtonSecondary.text)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        LottieImageViewSUI(jsonName: "pera-loader-purple-light", color: .black)
                            .frame(width: 30, height: 30)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }

                Circle()
                    .fill(isSwapDisabled ? Color.ButtonPrimary.disabledBg : Color.ButtonPrimary.bg)
                    .frame(width: circleSize, height: circleSize)
                    .overlay(
                        Image("icon-arrow-24")
                            .renderingMode(.template)
                            .foregroundColor(Color.Defaults.bg)
                    )
                    .opacity(state.buttonAndTextOpacity)
                    .offset(x: dragOffset + 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if state == .idle {
                                    dragOffset = min(max(0, value.translation.width), geometry.size.width - circleSize - 4)
                                }
                            }
                            .onEnded { _ in
                                if dragOffset > geometry.size.width * 0.6 {
                                    dragOffset = geometry.size.width - circleSize - 4
                                    state = .loading
                                    onConfirm()
                                } else {
                                    dragOffset = 0
                                }
                            }
                    )
            }
            .frame(height: buttonHeight)
            .frame(maxWidth: .infinity)
            .animation(.easeInOut(duration: 0.2), value: dragOffset)
        }
        .frame(height: buttonHeight)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
