//
//  Alamofire+TaskConvertible.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Alamofire
import Foundation

extension Alamofire.DataRequest: TaskConvertible {
    public var taskIdentifier: Int {
        return task?.taskIdentifier ?? -1
    }

    public var inProgress: Bool {
        return task?.inProgress ?? false
    }

    public func cancelNow() {
        cancel()
    }
}

extension Alamofire.DataRequest {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return description
    }
}

extension Alamofire.DataRequest {
    func magpie_responseData(completionHandler: @escaping (AFDataResponse<Data>) -> Void) -> Self {
        return response(responseSerializer: DataResponseSerializer(emptyResponseCodes: Set(200..<300)), completionHandler: completionHandler)
    }
}
