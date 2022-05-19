//
//  Errors.swift
//  
//
//  Created by Jesse Suter on 5/18/22.
//

import Foundation

public enum BasicAuthenticationError: Error, CustomStringConvertible {
    case encodingError
    
    public var description: String {
        switch self {
        case .encodingError:
            return "Failed to encode credentials!"
        }
    }
}
