//
//  ResponseResolver.swift
//  Magpie
//
//  Created by Karasuluoglu on 19.12.2019.
//

import Foundation

public protocol ResponseResolver {
    func resolve(_ response: Response)
}

struct ResponseResultResolver<SomeModel: Model, SomeErrorModel: Model>: ResponseResolver {
    typealias CompletionHandler = (Response.Result<SomeModel, SomeErrorModel>, Headers) -> Void

    let completionHandler: CompletionHandler

    init(_ completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

    func resolve(_ response: Response) {
        completionHandler(response.decoded(), response.headers)
    }
}

struct ResponseRawResultResolver: ResponseResolver {
    typealias CompletionHandler = (Response.RawResult, Headers) -> Void

    let completionHandler: CompletionHandler

    init(_ completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

    func resolve(_ response: Response) {
        completionHandler(response.decoded(), response.headers)
    }
}

struct ResponseModelResultResolver<SomeModel: Model>: ResponseResolver {
    typealias CompletionHandler = (Response.Result<SomeModel, NoModel>, Headers) -> Void

    let completionHandler: CompletionHandler

    init(_ completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

    func resolve(_ response: Response) {
        completionHandler(response.decoded(), response.headers)
    }
}

struct ResponseModelResolver<SomeModel: Model>: ResponseResolver {
    typealias CompletionHandler = (SomeModel?, Headers) -> Void

    let completionHandler: CompletionHandler

    init(_ completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

    func resolve(_ response: Response) {
        switch response.decoded() as Response.Result<SomeModel, NoModel> {
        case .success(let model):
            completionHandler(model, response.headers)
        case .failure:
            completionHandler(nil, response.headers)
        }
    }
}

struct ResponseErrorResultResolver<SomeErrorModel: Model>: ResponseResolver {
    typealias CompletionHandler = (Response.Result<NoModel, SomeErrorModel>, Headers) -> Void

    let completionHandler: CompletionHandler

    init(_ completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

    func resolve(_ response: Response) {
        completionHandler(response.decoded(), response.headers)
    }
}

struct ResponseErrorResolver: ResponseResolver {
    typealias CompletionHandler = (APIError?, Headers) -> Void

    let completionHandler: CompletionHandler

    init(_ completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler
    }

    func resolve(_ response: Response) {
        switch response.decoded() {
        case .success:
            completionHandler(nil, response.headers)
        case .failure(let error):
            completionHandler(error, response.headers)
        }
    }
}
