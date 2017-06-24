//
//  SwiftBusDictionaryKey.swift
//  Pods
//
//  Created by Adam Boyd on 2017/6/23.
//
//

import Foundation

//Base class

public struct SwiftBusDictionaryKey {
    var rawValue: String
    
    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension SwiftBusDictionaryKey: Hashable, Equatable {
    //Equatable
    public static func ==(lhs: SwiftBusDictionaryKey, rhs: SwiftBusDictionaryKey) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    //Hashable
    public var hashValue: Int {
        return self.rawValue.hashValue
    }
}

public typealias TransitAgencyTag = SwiftBusDictionaryKey
