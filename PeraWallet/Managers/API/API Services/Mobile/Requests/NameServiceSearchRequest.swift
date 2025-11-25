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

//   NameServiceSearchRequest.swift

struct NameServiceSearchRequest {
    /// The name or keyword to be searched within the name service.
    let name: String
}

extension NameServiceSearchRequest: QueryRequestable {
    
    typealias ResponseType = NameServiceSearchResponse
    
    var path: String { "/name-services/search" }
    var method: RequestMethod { .get }
}

struct NameServiceSearchResponse: Decodable {
    /// The list of name service entries that match the search query.
    let results: [NameService]
}

struct NameService: Decodable {
    /// The human-readable name.
    let name: String
    /// The address associated with the name.
    let address: String
    /// Information about the service that registered or manages the name.
    let service: Service
}

struct Service: Decodable {
    /// The name of the service.
    let name: String
    /// The URL for the service’s logo image.
    let logo: String
}
