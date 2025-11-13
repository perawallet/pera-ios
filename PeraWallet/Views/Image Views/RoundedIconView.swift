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

//   RoundedIconView.swift

import SwiftUI

struct RoundedIconView: View {
    
    // MARK: - Properties
    
    let image: ImageType
    let size: Double
    let padding: Double
    
    // MARK: - Body
    
    var body: some View {
        imageView(image: image)
            .cornerRadius(size / 2.0)
    }
    
    @ViewBuilder
    private func imageView(image: ImageType) -> some View {
        switch image {
        case let .data(data):
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: size, height: size)
            } else {
                EmptyView()
            }
        case let .icon(data):
            Image(data.image)
                .resizable()
                .foregroundColor(data.tintColor)
                .padding(padding)
                .frame(width: size, height: size)
                .background(data.backgroundColor)
                .cornerRadius(size / 2.0)
            
        }
    }
}
