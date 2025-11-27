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

//   InAppBrowserMessageParams.swift

struct URLParams: Decodable {
    let url: String
}

struct URIParams: Decodable {
    let uri: String
}

struct PushWVParams: Decodable {
    let url: String
    let title: String?
    let projectId: String?
    let isFavorite: Bool?
}

struct LogEventParams: Decodable {
    let name: String
    let payload: [String: String]?
}

struct NotifyParams: Decodable {
    let type: NotifyType
    let variant: String
    let message: String?
}

enum NotifyType: String, Decodable {
    case haptic
    case sound
    case message
}
