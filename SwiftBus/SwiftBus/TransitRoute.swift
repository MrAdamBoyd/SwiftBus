//
//  TransitRoute.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 com.adam. All rights reserved.
//

import Foundation
import UIKit

private let kRouteTagEncoderString = "kRouteTagEncoder"
private let kRouteTitleEncoderString = "kRouteTitleEncoder"
private let kStopsOnRouteEncoderString = "kStopsOnRouteEncoder"
private let kRouteColorEncoderString = "kRouteColorEncoder"
private let kOppositeColorEncoderString = "kOppositeColorEncoder"
private let kLatMinEncoderString = "kLatMinEncoder"
private let kLatMaxEncoderString = "kLatMaxEncoder"
private let kLonMinEncoderString = "kLonMinEncoder"
private let kLonMaxEncoderString = "kLonMaxEncoder"


class TransitRoute: NSObject, NSCoding {
    
    var routeTag:String = ""
    var routeTitle:String = ""
    var stopsOnRoute:[String : [TransitStop]] = [:]
    var routeColor:UIColor = UIColor()
    var oppositeColor:UIColor = UIColor()
    var latMin:Double = 0
    var latMax:Double = 0
    var lonMin:Double = 0
    var lonMax:Double = 0
    
    //Basic init
    override init() { super.init() }
    
    //Init without stops
    init(routeTag:String, routeTitle:String) {
        self.routeTag = routeTag
        self.routeTitle = routeTitle
    }
    
    //MARK: NSCoding
    
    required init(coder aDecoder: NSCoder) {
        routeTag = aDecoder.decodeObjectForKey(kRouteTagEncoderString) as! String
        routeTitle = aDecoder.decodeObjectForKey(kRouteTitleEncoderString) as! String
        stopsOnRoute = aDecoder.decodeObjectForKey(kStopsOnRouteEncoderString) as! [String : [TransitStop]]
        routeColor = aDecoder.decodeObjectForKey(kRouteColorEncoderString) as! UIColor
        oppositeColor = aDecoder.decodeObjectForKey(kOppositeColorEncoderString) as! UIColor
        latMin = aDecoder.decodeDoubleForKey(kLatMinEncoderString)
        latMax = aDecoder.decodeDoubleForKey(kLatMaxEncoderString)
        lonMin = aDecoder.decodeDoubleForKey(kLonMinEncoderString)
        lonMax = aDecoder.decodeDoubleForKey(kLonMaxEncoderString)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(routeTag, forKey: kRouteTagEncoderString)
        aCoder.encodeObject(routeTitle, forKey: kRouteTitleEncoderString)
        aCoder.encodeObject(stopsOnRoute, forKey: kStopsOnRouteEncoderString)
        aCoder.encodeObject(routeColor, forKey: kRouteColorEncoderString)
        aCoder.encodeObject(oppositeColor, forKey: kOppositeColorEncoderString)
        aCoder.encodeDouble(latMin, forKey: kLatMinEncoderString)
        aCoder.encodeDouble(latMax, forKey: kLatMaxEncoderString)
        aCoder.encodeDouble(lonMin, forKey: kLonMinEncoderString)
        aCoder.encodeDouble(lonMax, forKey: kLonMaxEncoderString)
    }
}