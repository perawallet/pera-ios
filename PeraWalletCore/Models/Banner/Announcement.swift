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

//   Announcement.swift

import Foundation

/// <todo>
/// Rethink the paginated list model. Should be more reusable.
public final class AnnouncementList:
    PaginatedList<Announcement>,
    ALGEntityModel {
    public convenience init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.init(
            pagination: apiModel,
            results: apiModel.results.unwrap(or: [])
        )
    }

    public func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.count = count
        apiModel.next = next
        apiModel.previous = previous
        apiModel.results = results
        return apiModel
    }
}

extension AnnouncementList {
    public struct APIModel:
        ALGAPIModel,
        PaginationComponents {
        public var count: Int?
        public var next: URL?
        public var previous: String?
        public var results: [Announcement]?

        public init() {
            self.count = nil
            self.next = nil
            self.previous = nil
            self.results = []
        }
    }
}

public final class Announcement: ALGAPIModel {
    public let id: String
    public let type: AnnouncementType
    public let title: String?
    public let subtitle: String?
    public let buttonLabel: String?
    public let buttonUrl: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        self.id = String(id)
        self.type = try container.decode(AnnouncementType.self, forKey: .type)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.buttonLabel = try container.decodeIfPresent(String.self, forKey: .buttonLabel)
        self.buttonUrl = try container.decodeIfPresent(String.self, forKey: .buttonUrl)
    }
    
    public init() {
        id = "invalidID"
        type = .generic
        title = nil
        subtitle = nil
        buttonLabel = nil
        buttonUrl = nil
    }

    public init(type: AnnouncementType) {
        self.id = type.rawValue
        self.type = type
        self.title = nil
        self.subtitle = nil
        self.buttonLabel = nil
        self.buttonUrl = nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case subtitle
        case buttonLabel = "button_label"
        case buttonUrl = "button_url"
    }
    
}

public enum AnnouncementType: String, Codable {
    case governance
    case generic
    case backup
    case staking
    case card
    
    public init?(rawValue: String) {
        switch rawValue {
        case "governance":
            self = .governance
        case "backup":
            self = .backup
        case "staking":
            self = .staking
        case "card":
            self = .card
        default:
            self = .generic
        }
    }
    
    public static func == (lhs: AnnouncementType, rhs: AnnouncementType) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}
