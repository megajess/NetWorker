//
//  HTTPSupport.swift
//  NetWorker
//
//  Created by Jesse Suter on 3/9/22.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public enum HTTPContentType: String {
    case applicationJson = "application/json"
    case multipartFormData = "multipart/form-data"
}

public enum ParamType {
    case path([String : Any])
    case query([String : Any])
    case body([String : Any])
}
