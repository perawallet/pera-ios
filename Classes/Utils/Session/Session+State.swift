// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   Session+State.swift

import Foundation

extension Session {
    func saveRememberState(_ state: RememberState) {
        var states = self.rememberedStates
        states[state.rawValue()] = state

        rememberedStates = states
    }

    func hasRememberState(for state: RememberState) -> Bool {
        rememberedStates[state.rawValue()] != nil
    }
}

extension Session {
    enum RememberState: Codable {
        case banner(id: Int)

        func rawValue() -> String {
            switch self {
            case .banner(let id):
                return "banner-\(id)"
            }
        }
    }
}
