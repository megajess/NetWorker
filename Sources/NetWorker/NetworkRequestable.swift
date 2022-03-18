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
    
    static func url(params: [URLParamType]?) -> URL?
    static func buildRequest(params: [URLParamType]?, body: AnyEncodable?) throws -> URLRequest
}

extension NetworkRequestable {
    // TODO: JRS: Use URLComponents?
    public static func url(params: [URLParamType]?) -> URL? {

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
            case .query(_):
                finalURLString = Self.urlString
            }
        }
        
        return URL(string: finalURLString)
    }
    
    public static func buildRequest(with params: [URLParamType]?, and body: AnyEncodable?) throws -> URLRequest {
        
        guard let url = url(params: params) else {
            throw NetworkRequestableError.invalidURL
        }
        
        var request = URLRequest(url: url)
        
        if let body = body, let bodyData = try? JSONEncoder().encode(body.self) {
            request.httpBody = bodyData
        }
        
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        
        return request
    }
}
