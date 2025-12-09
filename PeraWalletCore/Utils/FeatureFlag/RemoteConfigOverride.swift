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

//   RemoteConfigOverride.swift

public struct RemoteConfigOverride {

    public static var overrideValues: [String: Bool] {
        get {
            PeraUserDefaults.overrideRemoteConfigValues ?? [:]
        }
        set {
            PeraUserDefaults.overrideRemoteConfigValues = newValue
        }
    }
    
    public static func isEnabled(for key: String) -> Bool {
        return overrideValues[key] != nil
    }

    public static func value(for key: String) -> Bool? {
        overrideValues[key]
    }

    public static func set(_ value: Bool, for key: String) {
        var overrides = overrideValues
        overrides[key] = value
        overrideValues = overrides
    }
    
    public static func remove(for key: String) {
        var overrides = overrideValues
        overrides.removeValue(forKey: key)
        overrideValues = overrides
    }

    public static func clear() {
        overrideValues = [:]
    }
}
