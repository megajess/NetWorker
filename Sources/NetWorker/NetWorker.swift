//
//  NetWorker.swift
//  NetWorker
//
//  Created by Jesse Suter on 3/9/22.
//

import Foundation

public class NetWorker {
    
    private init() {}
    
    public static var current: NetWorker = NetWorker()
    
    public func process<T: Codable>(_ requestBuilder: NetworkRequestable.Type, using urlParams: [URLParamType]?, with body: AnyEncodable?, expecting: T.Type?, completion: @escaping (T?, Int?) -> Void) {
        do {
            let request = try requestBuilder.buildRequest(params: urlParams, body: body)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                let responseCode = (response as? HTTPURLResponse)?.statusCode
                
                guard error == nil, let data = data else {
                    completion(nil, responseCode)
                    return
                }
                
                if let expecting = expecting {
                    if let response = try? JSONDecoder().decode(expecting.self, from: data) {
                        completion(response, responseCode)
                    } else {
                        completion(nil, responseCode)
                    }
                } else {
                    completion(nil, responseCode)
                }
            }
            
            task.resume()
            
        } catch let error as NetworkRequestableError {
            print(error.message)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
