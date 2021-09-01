//
//  EndpointOperatable.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 13.09.2018.
//

import Foundation

public protocol EndpointOperatable: Printable {
    var request: Request { get }

    func setAdditionalHeader(_ header: Header, _ policy: AdditionalHeaderPolicy)

    @discardableResult
    func send() -> EndpointOperatable
    func retry()
    func cancel()
}

public enum AdditionalHeaderPolicy {
    case alwaysOverride
    case setIfNotExists
}
