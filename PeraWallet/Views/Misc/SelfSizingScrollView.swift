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

//   SelfSizingScrollView.swift

import SwiftUI

struct SelfSizingScrollView<Model: Identifiable, Content: View>: View {
    
    // MARK: - Properties
    
    let models: [Model]
    @ViewBuilder var content: (Model) -> Content
    @State private var scrollViewContentSize: CGSize = .zero
    
    // MARK: - Body
    
    var body: some View {
        
        ScrollView {
            VStack {
                ForEach(models, content: content)
            }
            .background(
                GeometryReader { geometry -> Color in
                    DispatchQueue.main.async {
                        scrollViewContentSize = geometry.size
                    }
                    return Color.clear
                }
            )
        }
        .frame(maxHeight: scrollViewContentSize.height)
    }
}
