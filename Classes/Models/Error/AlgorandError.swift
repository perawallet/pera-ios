//
//  AlgorandError.swift

import Magpie

class AlgorandError: Model & Encodable {
    let type: String
    let message: String?
}

extension AlgorandError {
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case message = "fallback_message"
    }
}

extension AlgorandError {
    enum ErrorType: String {
        case deviceAlreadyExists = "DeviceAlreadyExistsException"
    }
}
