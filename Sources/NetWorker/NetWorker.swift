//
//  JSONDecoderWithCustomDateFormatters.swift
//  NetWorker
//
//  Created by Jesse Suter on 3/9/22.
//

import Foundation

public class NetWorker {
    
    private init() {}
    
    public static var current: NetWorker = NetWorker()
    
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
        } catch let error {
            completion(nil, nil, error)
        }
    }
}
