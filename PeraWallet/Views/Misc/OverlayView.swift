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

//   OverlayView.swift

import SwiftUI

struct OverlayView<Content: View>: View {
    
    // MARK: - Constants
    
    private let dismissDragOffset = 100.0
    
    // MARK: - Properties
    
    @ViewBuilder let contentView: () -> Content
    
    @Binding var isVisible: Bool
    @State private var dragOffset: CGFloat = 0
    
    // MARK: - Properties - UIKit Compatibility
    
    var onDismissAction: (() -> Void)
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isVisible {
                Color.Backdrop.modalBg
                    .ignoresSafeArea()
            }
            if isVisible {
                VStack {
                    Spacer()
                    VStack(spacing: 0.0) {
                        Capsule()
                            .foregroundStyle(Color.Layer.grayLight)
                            .frame(width: 36.0, height: 4.0)
                            .padding(.top, 12.0)
                        contentView()
                    }
                        .background(
                            Color.Defaults.bg
                                .clipShape(.rect(topLeadingRadius: 8.0, topTrailingRadius: 8.0))
                                .ignoresSafeArea()
                        )
                }
                .zIndex(1.0)
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged {
                            guard $0.translation.height >= 0.0 else { return }
                            dragOffset = $0.translation.height
                        }
                        .onEnded {
                            if $0.translation.height > dismissDragOffset {
                                onDismissAction()
                                isVisible = false
                            } else {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.6), value: isVisible)
        .onAppear { isVisible = true }
    }
}
