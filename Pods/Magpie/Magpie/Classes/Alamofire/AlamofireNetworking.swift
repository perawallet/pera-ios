//
//  AlamofireNetworking.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Alamofire
import Foundation

open class AlamofireNetworking: Networking {
    public init() { }

    open func send(_ request: Request, validateResponse: Bool, onReceived handler: @escaping ResponseHandler) -> TaskConvertible? {
        do {
            let urlRequest = try request.asUrlRequest()
            let dataRequest = AF.request(urlRequest)

            if validateResponse {
                dataRequest.validate()
            }
            return dataRequest.magpie_responseData { [weak self] dataResponse in
                if let self = self {
                    handler(self.populateResponse(dataResponse, for: request))
                }
            }
        } catch let error {
            handler(populateResponse(error, for: request))
            return nil
        }
    }

    open func upload(_ source: EndpointType.Source, with request: Request, validateResponse: Bool, onCompleted handler: @escaping ResponseHandler) -> TaskConvertible? {
        do {
            let urlRequest = try request.asUrlRequest()

            let uploadRequest: UploadRequest

            switch source {
            case .data(let data):
                uploadRequest = AF.upload(data, with: urlRequest)
            case .file(let url):
                uploadRequest = AF.upload(url, with: urlRequest)
            }

            if validateResponse {
                uploadRequest.validate()
            }
            return uploadRequest.magpie_responseData { [weak self] dataResponse in
                if let self = self {
                    handler(self.populateResponse(dataResponse, for: request))
                }
            }
        } catch let error {
            handler(populateResponse(error, for: request))
            return nil
        }
    }

    open func upload(_ form: MultipartForm, with request: Request, validateResponse: Bool, onCompleted handler: @escaping ResponseHandler) -> TaskConvertible? {
        do {
            let urlRequest = try request.asUrlRequest()
            let uploadRequest = AF.upload(
                multipartFormData: { multipartFormData in
                    form.append(into: multipartFormData)
                },
                with: urlRequest
            )

            if validateResponse {
                uploadRequest.validate()
            }
            return uploadRequest.magpie_responseData { [weak self] dataResponse in
                if let self = self {
                    handler(self.populateResponse(dataResponse, for: request))
                }
            }
        } catch let error {
            handler(populateResponse(error, for: request))
            return nil
        }
    }
}

extension AlamofireNetworking {
    private func populateResponse(_ dataResponse: AFDataResponse<Data>, for request: Request) -> Response {
        switch dataResponse.result {
        case .success:
            return Response(request: request, rawHeaders: dataResponse.response?.allHeaderFields, rawData: dataResponse.data)
        case .failure(let afError):
            let error = populateError(afError, with: dataResponse.data)
            return Response(request: request, rawHeaders: dataResponse.response?.allHeaderFields, rawData: dataResponse.data, error: error)
        }
    }

    private func populateError(_ afError: AFError, with data: Data?) -> APIError {
        switch afError {
        case .explicitlyCancelled:
            return ConnectionError(reason: .cancelled)
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                return HTTPError(statusCode: code, responseData: data, underlyingError: afError)
            } else {
                return UnexpectedError(responseData: data, underlyingError: afError)
            }
        case .sessionTaskFailed(let error):
            if let urlError = error as? URLError {
                return ConnectionError(urlError: urlError)
            } else {
                return UnexpectedError(responseData: data, underlyingError: error)
            }
        default:
            return UnexpectedError(responseData: data, underlyingError: afError)
        }
    }

    private func populateResponse(_ error: Error, for request: Request) -> Response {
        if let apiError = error as? APIError {
            return Response(request: request, error: apiError)
        }
        return Response(request: request, error: UnexpectedError(responseData: nil, underlyingError: error))
    }
}
