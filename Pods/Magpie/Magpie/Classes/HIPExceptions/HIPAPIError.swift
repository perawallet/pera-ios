//
//  HipoException.swift
//  Magpie
//
//  Created by Karasuluoglu on 20.12.2019.
//

import Foundation

public struct HIPAPIError: Model {
    public static var localFallbackMessage = "Something went wrong!"

    public let type: String?
    public let detail: HIPAPIErrorDetail?
    public let fallbackMessage: String

    public init(
        type: String? = nil,
        detail: HIPAPIErrorDetail? = nil,
        fallbackMessage: String? = nil
    ) {
        self.type = type
        self.detail = detail
        self.fallbackMessage = fallbackMessage ?? HIPAPIError.localFallbackMessage
    }

    /// <mark> Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        detail = try container.decodeIfPresent(HIPAPIErrorDetail.self, forKey: .detail)
        fallbackMessage = try container.decodeIfPresent(String.self, forKey: .fallbackMessage) ?? HIPAPIError.localFallbackMessage
    }

    /// <mark> Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(detail, forKey: .detail)
        try container.encode(fallbackMessage, forKey: .fallbackMessage)
    }
}

extension HIPAPIError {
    /// <note> Path messages > Non-field messages > Fallback message
    public func message(_ path: String...) -> String {
        return findFieldDetail(at: path)?.messages?.first ?? detail?.nonFieldMessages?.first ?? fallbackMessage
    }

    public func messages(_ path: String...) -> [String] {
        return findFieldDetail(at: path)?.messages ?? detail?.nonFieldMessages ?? [fallbackMessage]
    }

    public func fieldMessage(_ path: String...) -> String? {
        return findFieldDetail(at: path)?.messages?.first
    }

    public func fieldMessages(_ path: String...) -> [String]? {
        return findFieldDetail(at: path)?.messages
    }
}

extension HIPAPIError {
    private func findFieldDetail(at path: [String]) -> HIPAPIErrorField.Detail? {
        var fieldDetail: HIPAPIErrorField.Detail?

        for (i, fieldName) in path.enumerated() {
            if i == path.startIndex {
                fieldDetail = detail?[fieldName]
            } else {
                fieldDetail = fieldDetail?[fieldName]
            }
        }
        return fieldDetail
    }
}

extension HIPAPIError {
    private enum CodingKeys: String, CodingKey {
        case type
        case detail
        case fallbackMessage = "fallback_message"
    }
}

public struct HIPAPIErrorDetail: Model {
    public let nonFieldMessages: [String]?
    public let fields: [HIPAPIErrorField]?

    public init(
        nonFieldMessages: [String]? = nil,
        fields: [HIPAPIErrorField]? = nil
    ) {
        self.nonFieldMessages = nonFieldMessages
        self.fields = fields
    }

    /// <mark> Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: HIPAPIErrorMessagesCodingKey.self)

        var nonFieldMessages: [String]?
        var fields: [HIPAPIErrorField]?

        for key in container.allKeys {
            if key == HIPAPIErrorMessagesCodingKey.nonFieldMessages() {
                nonFieldMessages = try container.decodeIfPresent([String].self, forKey: key)
            } else {
                let fieldDetail = try container.decodeIfPresent(HIPAPIErrorField.Detail.self, forKey: key)
                let field = HIPAPIErrorField(name: key.stringValue, detail: fieldDetail)

                if let oldFields = fields {
                    fields = oldFields + [field]
                } else {
                    fields = [field]
                }
            }
        }
        self.nonFieldMessages = nonFieldMessages
        self.fields = fields
    }

    /// <mark> Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: HIPAPIErrorMessagesCodingKey.self)
        try container.encodeIfPresent(nonFieldMessages, forKey: .nonFieldMessages())

        if let fields = fields {
            try fields.forEach { try container.encodeIfPresent($0.detail, forKey: HIPAPIErrorMessagesCodingKey(stringValue: $0.name)!) }
        }
    }
}

extension HIPAPIErrorDetail {
    public subscript (fieldName: String) -> HIPAPIErrorField.Detail? {
        return fields?[fieldName]
    }
}

public struct HIPAPIErrorField: Model {
    public let name: String
    public let detail: Detail?

    public init(
        name: String,
        detail: Detail? = nil
    ) {
        self.name = name
        self.detail = detail
    }
}

extension HIPAPIErrorField {
    public static func ~> (base: Self, subs: [Self]) -> Self {
        return HIPAPIErrorField(name: base.name, detail: .subfields(subs))
    }
}

extension HIPAPIErrorField {
    public enum Detail: Model {
        case messages([String])
        case subfields([HIPAPIErrorField])

        /// <mark> Decodable
        public init(from decoder: Decoder) throws {
            do {
                var container = try decoder.unkeyedContainer()
                var messages: [String] = []

                while !container.isAtEnd {
                    if let message = try container.decodeIfPresent(String.self) {
                        messages.append(message)
                    }
                }
                self = .messages(messages)
            } catch DecodingError.typeMismatch {
                let container = try decoder.container(keyedBy: HIPAPIErrorMessagesCodingKey.self)
                var subfields: [HIPAPIErrorField] = []

                for key in container.allKeys {
                    let detail = try container.decodeIfPresent(HIPAPIErrorField.Detail.self, forKey: key)
                    subfields.append(HIPAPIErrorField(name: key.stringValue, detail: detail))
                }
                self = .subfields(subfields)
            }
        }

        /// <mark> Encodable
        public func encode(to encoder: Encoder) throws {
            switch self {
                case .messages(let messages):
                    var container = encoder.unkeyedContainer()

                    for message in messages {
                        try container.encode(message)
                    }
                case .subfields(let subfields):
                    var container = encoder.container(keyedBy: HIPAPIErrorMessagesCodingKey.self)

                    for subfield in subfields {
                        try container.encodeIfPresent(subfield.detail, forKey: HIPAPIErrorMessagesCodingKey(stringValue: subfield.name)!)
                    }
            }
        }
    }
}

extension HIPAPIErrorField.Detail {
    public var messages: [String]? {
        if case .messages(let someMessages) = self {
            return someMessages
        }
        return nil
    }
    public var subfields: [HIPAPIErrorField]? {
        if case .subfields(let someSubfields) = self {
            return someSubfields
        }
        return nil
    }
}

extension HIPAPIErrorField.Detail {
    public subscript (subfieldName: String) -> HIPAPIErrorField.Detail? {
        return subfields?[subfieldName]
    }
}

struct HIPAPIErrorMessagesCodingKey: CodingKey, Equatable {
    var stringValue: String
    var intValue: Int? {
        return nil
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }

    static func nonFieldMessages() -> HIPAPIErrorMessagesCodingKey {
        return HIPAPIErrorMessagesCodingKey(stringValue: "non_field_errors")!
    }
}

extension Array where Element == HIPAPIErrorField {
    public subscript (fieldName: String) -> HIPAPIErrorField.Detail? {
        return first { $0.name == fieldName }?.detail
    }
}
