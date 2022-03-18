//
//  AnyEncodable.swift
//  
//
//  Created by Jesse Suter on 3/17/22.
//

import Foundation

public struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    
    public init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }
    
    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
