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
    
    public func process<T: Codable>(
        _ requestBuilder: NetworkRequestable.Type,
        urlParams: [URLParamType]? = nil,
        body: AnyEncodable? = nil,
        expecting: T.Type?,
        dateFormatters: [DateFormatter]? = nil,
        completion: @escaping (T?, Int?, Error?) -> Void
    ) {
        let decoder = JSONDecoderWithCustomDateFormatters()

        if let dateFormatters = dateFormatters {
            decoder.setDateDecodingStrategyFormatters(dateFormatters)
        }
        
        self.process(
            requestBuilder,
            urlParams: urlParams,
            body: body,
            expecting: expecting,
            decoder: decoder,
            completion: completion)
    }
    
    public func process<T: Codable>(
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
                let responseCode = (response as? HTTPURLResponse)?.statusCode
                
                guard error == nil, let data = data else {
                    completion(nil, responseCode, error)
                    return
                }
                
                do {
                    if let expecting = expecting {
                        let response = try decoder.decode(expecting.self, from: data)
                        completion(response, responseCode, nil)
                    } else {
                        completion(nil, responseCode, nil)
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
