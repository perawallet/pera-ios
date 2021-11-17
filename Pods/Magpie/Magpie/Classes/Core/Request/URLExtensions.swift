//
//  URLExtensions.swift
//  Magpie
//
//  Created by Karasuluoglu on 17.12.2019.
//

import Foundation

/// <reference> https://gist.github.com/shaps80/ba6a1e2d477af0383e8f19b87f53661d
extension URLRequest {
    public func asCURL() -> String? {
        guard let url = url else {
            return nil
        }
        let baseCommand = "curl \(url.absoluteString)"
        var command: [String] = []

        if let httpMethod = httpMethod {
            switch httpMethod {
            case "GET":
                command.append(baseCommand)
            case "HEAD":
                command.append("\(baseCommand) --head")
            default:
                command.append("\(baseCommand)")
                command.append("-X \(httpMethod)")
            }
        } else {
            command.append(baseCommand)
        }
        if let body = httpBody {
            if let bodyString = String(data: body, encoding: .utf8) {
                command.append("-d '\(bodyString)'")
            }
        }
        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }
        return command.joined(separator: " \\\n\t")
    }
}

extension URLSessionTask {
    var inProgress: Bool {
        return state == .running || state == .suspended
    }
}
