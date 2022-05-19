//
//  JSONDecoderWithCustomDateFormatters.swift
//  NetWorker
//
//  Created by Jesse Suter on 3/9/22.
//

import Foundation
import os

public class NetWorker {
    
    private init() {}
    
    public static var current: NetWorker = NetWorker()
    public var token: String?
    
    public func processJSONRequest<T: Codable>(
        _ requestBuilder: NetworkRequestable.Type,
        urlParams: [URLParamType]? = nil,
        body: AnyEncodable? = nil,
        expecting: T.Type?,
        completion: @escaping (T?, Int?, Error?) -> Void
    ) {
        let decoder = JSONDecoderWithCustomDateFormatters()
        
        self.processJSONRequest(
            requestBuilder,
            urlParams: urlParams,
            body: body,
            expecting: expecting,
            decoder: decoder,
            completion: completion)
    }
    
    public func processJSONRequest<T: Codable>(
        _ requestBuilder: NetworkRequestable.Type,
        urlParams: [URLParamType]? = nil,
        body: AnyEncodable? = nil,
        expecting: T.Type?,
        dateFormatters: [DateFormatter],
        completion: @escaping (T?, Int?, Error?) -> Void
    ) {
        let decoder = JSONDecoderWithCustomDateFormatters()

        decoder.setDateDecodingStrategyFormatters(dateFormatters)
        
        self.processJSONRequest(
            requestBuilder,
            urlParams: urlParams,
            body: body,
            expecting: expecting,
            decoder: decoder,
            completion: completion)
    }
    
    public func processBasicAuthorizationRequest<T: Codable>(
        _ loginURL: URL,
        urlParams: [URLParamType]? = nil,
        username: String,
        password: String,
        expecting: T.Type?,
        completion: @escaping (T?, Int?, Error?) -> Void
    ) {
        guard let loginString = "\(username):\(password)"
            .data(using: .utf8)?
            .base64EncodedString() else {

            completion(nil, nil, BasicAuthenticationError.encodingError)

            return
        }

        var request = URLRequest(url: loginURL)

        request.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.post.rawValue
        
        self.processJSONRequest(
            request,
            expecting: expecting,
            decoder: JSONDecoderWithCustomDateFormatters(),
            completion: completion)
    }
   
    public func processJSONRequest<T: Codable>(
        _ requestBuilder: NetworkRequestable.Type,
        urlParams: [URLParamType]? = nil,
        body: AnyEncodable? = nil,
        expecting: T.Type?,
        decoder: JSONDecoder,
        completion: @escaping (T?, Int?, Error?) -> Void
    ) {
        do {
            let request = try requestBuilder.buildRequest(urlParams, body)
            
            self.processJSONRequest(request,
                                    expecting: expecting,
                                    decoder: decoder,
                                    completion: completion)
        } catch let error {
            completion(nil, nil, error)
        }
    }
    
    public func processJSONRequest<T: Codable>(
        _ request: URLRequest,
        expecting: T.Type?,
        decoder: JSONDecoder,
        completion: @escaping (T?, Int?, Error?) -> Void
    ) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let responseStatusCode = (response as? HTTPURLResponse)?.statusCode
            
            guard error == nil, let data = data else {
                completion(nil, responseStatusCode, error)
                return
            }
            
            do {
                if let expecting = expecting {
                    let response = try decoder.decode(expecting.self, from: data)
                    completion(response, responseStatusCode, nil)
                } else {
                    completion(nil, responseStatusCode, nil)
                }
            } catch let decodeError {
                completion(nil, nil, decodeError)
            }
        }
        
        task.resume()
    }
}
