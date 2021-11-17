//
//  EndpointBuilder.swift
//  Magpie
//
//  Created by Karasuluoglu on 18.12.2019.
//

import Foundation

open class EndpointBuilder {
    let endpoint: Endpoint

    public init(api: API) {
        self.endpoint = Endpoint(api: api)
    }

    @discardableResult
    public func type(_ someType: EndpointType) -> Self {
        endpoint.type = someType
        return self
    }

    @discardableResult
    public func base(_ someBase: String) -> Self {
        endpoint.set(base: someBase)
        return self
    }

    @discardableResult
    public func path(_ somePath: String) -> Self {
        endpoint.set(path: somePath)
        return self
    }

    @discardableResult
    public func method(_ someMethod: Method) -> Self {
        endpoint.set(method: someMethod)
        return self
    }

    @discardableResult
    public func query(_ someQuery: Query) -> Self {
        endpoint.set(query: someQuery)
        return self
    }

    @discardableResult
    public func body(_ someBody: Body) -> Self {
        endpoint.set(body: someBody)
        return self
    }

    @discardableResult
    public func headers(_ someHeaders: Headers) -> Self {
        endpoint.set(headers: someHeaders)
        return self
    }

    @discardableResult
    public func timeout(_ someTimeout: TimeInterval) -> Self {
        endpoint.set(timeout: someTimeout)
        return self
    }

    @discardableResult
    public func cachePolicy(_ someCachePolicy: URLRequest.CachePolicy) -> Self {
        endpoint.set(cachePolicy: someCachePolicy)
        return self
    }

    @discardableResult
    public func validateResponseBeforeEndpointCompleted(_ shouldValidate: Bool) -> Self {
        endpoint.validatesResponseBeforeCompletion = shouldValidate
        return self
    }

    @discardableResult
    public func ignoreResponseWhenEndpointCancelled(_ shouldIgnore: Bool) -> Self {
        endpoint.ignoresResponseOnCancelled = shouldIgnore
        return self
    }

    @discardableResult
    public func ignoreResponseWhenEndpointListenersNotified(_ shouldIgnore: Bool) -> Self {
        endpoint.ignoresResponseWhenListenersNotified = shouldIgnore
        return self
    }

    @discardableResult
    public func notifyListenersWhenEndpointFailedFromUnauthorizedRequest(_ shouldNotify: Bool) -> Self {
        endpoint.notifiesListenersOnFailedFromUnauthorizedRequest = shouldNotify
        return self
    }

    @discardableResult
    public func notifyListenersWhenEndpointFailedFromUnavailableNetwork(_ shouldNotify: Bool) -> Self {
        endpoint.notifiesListenersOnFailedFromUnavailableNetwork = shouldNotify
        return self
    }

    @discardableResult
    public func notifyListenersWhenEndpointFailedFromDefectiveClient(_ shouldNotify: Bool) -> Self {
        endpoint.notifiesListenersOnFailedFromDefectiveClient = shouldNotify
        return self
    }

    @discardableResult
    public func notifyListenersWhenEndpointFailedFromUnresponsiveServer(_ shouldNotify: Bool) -> Self {
        endpoint.notifiesListenersOnFailedFromUnresponsiveServer = shouldNotify
        return self
    }

    @discardableResult
    public func completionHandler<SomeModel: Model, SomeErrorModel: Model>(_ someCompletionHandler: @escaping (Response.Result<SomeModel, SomeErrorModel>, Headers) -> Void) -> Self {
        endpoint.responseResolver = ResponseResultResolver(someCompletionHandler)
        return self
    }

    @discardableResult
    public func completionHandler<SomeModel: Model, SomeErrorModel: Model>(_ someCompletionHandler: @escaping (Response.Result<SomeModel, SomeErrorModel>) -> Void) -> Self {
        return completionHandler({ result, _ in someCompletionHandler(result) })
    }

    @discardableResult
    public func completionHandler(_ someCompletionHandler: @escaping (Response.RawResult, Headers) -> Void) -> Self {
        endpoint.responseResolver = ResponseRawResultResolver(someCompletionHandler)
        return self
    }

    @discardableResult
    public func completionHandler(_ someCompletionHandler: @escaping (Response.RawResult) -> Void) -> Self {
        return completionHandler({ result, _ in someCompletionHandler(result) })
    }

    @discardableResult
    public func completionHandler<SomeModel: Model>(_ someCompletionHandler: @escaping (Response.ModelResult<SomeModel>, Headers) -> Void) -> Self {
        endpoint.responseResolver = ResponseModelResultResolver(someCompletionHandler)
        return self
    }

    @discardableResult
    public func completionHandler<SomeModel: Model>(_ someCompletionHandler: @escaping (Response.ModelResult<SomeModel>) -> Void) -> Self {
        return completionHandler({ result, _ in someCompletionHandler(result) })
    }

    @discardableResult
    public func completionHandler<SomeModel: Model>(_ someCompletionHandler: @escaping (SomeModel?, Headers) -> Void) -> Self {
        endpoint.responseResolver = ResponseModelResolver(someCompletionHandler)
        return self
    }

    @discardableResult
    public func completionHandler<SomeModel: Model>(_ someCompletionHandler: @escaping (SomeModel?) -> Void) -> Self {
        return completionHandler({ result, _ in someCompletionHandler(result) })
    }

    @discardableResult
    public func completionHandler<SomeErrorModel: Model>(_ someCompletionHandler: @escaping (Response.ErrorModelResult<SomeErrorModel>, Headers) -> Void) -> Self {
        endpoint.responseResolver = ResponseErrorResultResolver(someCompletionHandler)
        return self
    }

    @discardableResult
    public func completionHandler<SomeErrorModel: Model>(_ someCompletionHandler: @escaping (Response.ErrorModelResult<SomeErrorModel>) -> Void) -> Self {
        return completionHandler({ result, _ in someCompletionHandler(result) })
    }

    @discardableResult
    public func completionHandler(_ someCompletionHandler: @escaping (APIError?, Headers) -> Void) -> Self {
        endpoint.responseResolver = ResponseErrorResolver(someCompletionHandler)
        return self
    }

    @discardableResult
    public func completionHandler(_ someCompletionHandler: @escaping (APIError?) -> Void) -> Self {
        return completionHandler({ result, _ in someCompletionHandler(result) })
    }

    @discardableResult
    public func responseResolver(_ someResponseResolver: ResponseResolver) -> Self {
        endpoint.responseResolver = someResponseResolver
        return self
    }

    public func build() -> EndpointOperatable {
        return endpoint
    }
}

