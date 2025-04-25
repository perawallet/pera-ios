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

//   UserDefault.swift

import Foundation

@propertyWrapper struct UserDefault<T: Codable> {

    private let key: String
    private let userDefaults: UserDefaults

    init(key: String, suiteName: String? = nil) {
        self.key = key
        userDefaults = UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
    }

    var wrappedValue: T? {
        get {
            guard let encodedData = UserDefaults.standard.data(forKey: key) else { return nil }
            return try? JSONDecoder().decode(T.self, from: encodedData)
        }
        set {
            guard let encodedValue = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(encodedValue, forKey: key)
        }
    }
}
