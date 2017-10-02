//
//  SwiftBusError.swift
//  Pods
//
//  Created by Adam on 10/2/17.
//

import Foundation

private let SwiftBusErrorDomain = "com.SwiftBus.SwiftBus.ErrorDomain"

enum SwiftBusErrorType: Int {
    case malformedURL = 0, unknownAgency, unknownStop, unspecifiedStopTag, unspecifiedAgencyTag
    
    var description: String {
        switch self {
        case .malformedURL:         return "The URL used in the request was not formatted correctly"
        case .unknownAgency:        return "The specified agency could not be found"
        case .unknownStop:          return "The specified stop could not be found"
        case .unspecifiedStopTag:   return "No stop tag specified"
        case .unspecifiedAgencyTag: return "No agency tag specified"
        }
    }
}

class SwiftBusError {
    class func error(with code: SwiftBusErrorType) -> NSError {
        return NSError(domain: SwiftBusErrorDomain, code: code.rawValue, userInfo: [NSLocalizedDescriptionKey: code.description])
    }
}
