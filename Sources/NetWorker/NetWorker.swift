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
    
    public func process<T: Codable>(_ requestBuilder: NetworkRequestable.Type, urlParams: [URLParamType]? = nil, body: AnyEncodable? = nil, expecting: T.Type?, dateFormatters: [DateFormatter]? = nil, completion: @escaping (T?, Int?) -> Void) {
        do {
            let request = try requestBuilder.buildRequest(urlParams, body)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                let responseCode = (response as? HTTPURLResponse)?.statusCode
                
                guard error == nil, let data = data else {
                    completion(nil, responseCode)
                    return
                }
                
                let decoder = JSONDecoderWithCustomdateFormatters()
                
                if let dateFormatters = dateFormatters {
                    decoder.setDateDecodingStrategyFormatters(dateFormatters)
                }
                
                if let expecting = expecting {
                    if let response = try? decoder.decode(expecting.self, from: data) {
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

class JSONDecoderWithCustomdateFormatters: JSONDecoder {
    var dateDecodingStrategyFormatters: [DateFormatter]?
    
    func setDateDecodingStrategyFormatters(_ dateFormatters: [DateFormatter]) {
        self.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            for formatter in dateFormatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
    }
}
