//
//  MultiPartForm.swift
//  Pods
//
//  Created by Karasuluoglu on 30.10.2020.
//

import Foundation

public protocol MultipartForm: Printable {
    func append(into formData: MultipartFormData)
}

public protocol MultipartFormData: AnyObject {
    func append(_ data: Data, withName name: String, fileName: String?, mimeType: String?)
    func append(_ fileURL: URL, withName name: String)
}

public struct DataMultipartForm: MultipartForm {
    public let data: Data
    public let name: String
    public let fileName: String?
    public let mimeType: MultipartContentMIMEType?

    public init(
        data: Data,
        name: String,
        fileName: String? = nil,
        mimeType: MultipartContentMIMEType? = nil
    ) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

extension DataMultipartForm {
    public func append(into formData: MultipartFormData) {
        formData.append(data, withName: name, fileName: fileName, mimeType: mimeType?.description)
    }
}

extension DataMultipartForm {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return """
        <data>
        Name: \(name)
        FileName: \(fileName ?? "<no-filename>")
        Mime Type: \(mimeType?.debugDescription ?? "<no-mime-type>")
        """
    }
}

public struct FileMultipartForm: MultipartForm {
    public let url: URL
    public let name: String

    public init(
        url: URL,
        name: String
    ) {
        self.url = url
        self.name = name
    }
}

extension FileMultipartForm {
    public func append(into formData: MultipartFormData) {
        formData.append(url, withName: name)
    }
}

extension FileMultipartForm {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return """
        <file>
        Url: \(url.absoluteString)
        Name: \(name)
        """
    }
}

public enum MultipartContentMIMEType: Printable {
    case png
    case jpg
    case pdf
    case doc
    case docx
    case other(String)

    init?(fileExtension: String) {
        switch fileExtension {
        case "png":
            self = .png
        case "jpg":
            self = .jpg
        case "pdf":
            self = .pdf
        case "doc":
            self = .doc
        case "docx":
            self = .docx
        default:
            return nil
        }
    }
}

extension MultipartContentMIMEType {
    /// <mark> CustomStringConvertible
    public var description: String {
        switch self {
        case .png:
            return "image/png"
        case .jpg:
            return "image/jpeg"
        case .pdf:
            return "application/pdf"
        case .doc:
            return "application/msword"
        case .docx:
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case .other(let someDescription):
            return someDescription
        }
    }

    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return description
    }
}
