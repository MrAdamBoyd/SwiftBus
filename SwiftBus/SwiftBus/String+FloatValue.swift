//
//  String+FloatValue.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-31.
//  Copyright (c) 2015 com.adam. All rights reserved.
//

import Foundation

extension String {
    
    /**
    Returns the float value of a string
    */
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    /**
    Subscript to allow for quick String substrings ["Hello"][0...1] = "He"
    */
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
}