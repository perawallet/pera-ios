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

//   BackButtonModifier.swift

import SwiftUI

struct BackButtonModifier: ViewModifier {
    
    // MARK: - Propterties
    
    @Binding var navigationPath: NavigationPath
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(.Icons.arrow)
                        .rotationEffect(.degrees(180.0))
                        .foregroundStyle(Color.Text.main)
                        .onTapGesture { navigationPath.removeLast() }
                }
            }
    }
}

extension View {
    func withPeraBackButton(navigationPath: Binding<NavigationPath>) -> some View {
        modifier(BackButtonModifier(navigationPath: navigationPath))
    }
}
