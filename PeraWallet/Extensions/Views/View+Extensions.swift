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

//   View+Extensions.swift

import SwiftUI

extension View {
    
    func defaultShadow() -> some View {
        shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 2)
        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 2)
        .shadow(color: .black.opacity(0.05), radius: 0, x: 0, y: 0)
    }
}
