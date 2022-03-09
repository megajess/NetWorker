//
//  NetworkRequestable.swift
//  NetWorker
//
//  Created by Jesse Suter on 3/9/22.
//

import Foundation

public enum NetworkRequestableError: Error {
    case invalidURL
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        }
    }
}

public protocol NetworkRequestable {
    static var urlString: String { get }
    static var method: HTTPMethod { get }
    static var contentType: HTTPContentType { get }
    
    static func url(params: [ParamType]?) -> URL?
    static func buildRequest(params: [ParamType]?) throws -> URLRequest
}

public extension NetworkRequestable {
    // TODO: JRS: Use URLComponents?
    public static func url(params: [ParamType]?) -> URL? {

        guard let params = params else {
            return URL(string: Self.urlString)
        }
        
        var finalURLString = ""
        
        for param in params {
            switch param {
            case .path(let kvp):
                let partParts = Self.urlString.split(separator: "/", omittingEmptySubsequences: false)
                
                let replacedParts: [String] = partParts.compactMap { part in
                    if kvp.contains(where: { key, _ in
                        part == key
                    }) {
                        return kvp[String(part)] as? String
                    } else {
                        return String(part)
                    }
                }
                
                finalURLString = replacedParts.joined(separator: "/")
            case .query(let kvp):
                finalURLString = Self.urlString
            case .body(let kvp):
                finalURLString = Self.urlString
            }
        }
        
        return URL(string: finalURLString)
    }
    
    public static func buildRequest(params: [ParamType]?) throws -> URLRequest {
        
        guard let url = url(params: params) else {
            throw NetworkRequestableError.invalidURL
        }
        
        var request = URLRequest(url: url)
        
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        
        return request
    }
}
