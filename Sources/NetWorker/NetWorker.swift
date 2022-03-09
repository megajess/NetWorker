//
//  NetWorker.swift
//  NetWorker
//
//  Created by Jesse Suter on 3/9/22.
//

import Foundation

final class NetWorker {
    
    private init() {}
    
    public static var current: NetWorker = NetWorker()
    
    public func process<T: Codable>(_ requestBuilder: NetworkRequestable.Type, expecting: T.Type, using params: [ParamType]?, completion: @escaping (T?) -> Void) {
        do {
            let request = try requestBuilder.buildRequest(params: params)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil, let data = data else {
                    completion(nil)
                    return
                }
                
                if let response = try? JSONDecoder().decode(T.self, from: data) {
                    completion(response)
                } else {
                    completion(nil)
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
