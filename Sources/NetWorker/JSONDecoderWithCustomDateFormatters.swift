//
//  JSONDecoderWithCustomDateFormatters.swift
//  
//
//  Created by Jesse Suter on 4/20/22.
//

import Foundation

internal class JSONDecoderWithCustomDateFormatters: JSONDecoder {
    var dateDecodingStrategyFormatters: [DateFormatter]?
    
    override init() {
        super.init()
        
        self.dateDecodingStrategy = .custom({ decoder in
            try self.dateDecodingStrategy(decoder)
        })
    }
    
    func dateDecodingStrategy(_ decoder: Decoder) throws -> Date {
        
        guard let dateDecodingStrategyFormatters = dateDecodingStrategyFormatters else {
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = DateFormatter().date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        for formatter in dateDecodingStrategyFormatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
    }
    
    func setDateDecodingStrategyFormatters(_ dateFormatters: [DateFormatter]) {
        self.dateDecodingStrategyFormatters = dateFormatters
    }
}
