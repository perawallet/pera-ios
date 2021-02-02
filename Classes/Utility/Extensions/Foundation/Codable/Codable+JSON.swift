//
//  Codable+JSON.swift

import SwiftDate
import Foundation

extension JSONEncoder.DateEncodingStrategy {
    static let shared: JSONEncoder.DateEncodingStrategy = {
        .custom({ date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(date.toISO())
        })
    }()
}

extension JSONDecoder.DateDecodingStrategy {
    enum DecodingError: Error {
        case parseFailed
    }
    
    static let shared: JSONDecoder.DateDecodingStrategy = {
        .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            guard let date = dateString.toISODate()?.date else {
                throw DecodingError.parseFailed
            }
            return date
        })
    }()
}
