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

//   LottieImageViewSUI.swift

import SwiftUI

struct LottieImageViewSUI: UIViewRepresentable {
    let jsonName: String
    var configuration: LottieImageView.Configuration = .init()
    var color: UIColor? = nil

    func makeUIView(context: Context) -> LottieImageView {
        let lottieView = LottieImageView()
        lottieView.setAnimation(jsonName)
        if let color = color {
            lottieView.setColor(color)
        }
        return lottieView
    }

    func updateUIView(_ uiView: LottieImageView, context: Context) {
        uiView.play(with: configuration)
    }
}
