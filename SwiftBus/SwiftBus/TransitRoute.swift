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
private let kAgencyTagEncoderString = "kAgencyTagEncoder"
private let kStopsOnRouteEncoderString = "kStopsOnRouteEncoder"
private let kDirectionTagToNameEncoderString = "kDirectionTagToNameEncoder"
private let kRouteColorEncoderString = "kRouteColorEncoder"
private let kOppositeColorEncoderString = "kOppositeColorEncoder"
private let kVehiclesOnRouteEncoderString = "kVehiclesOnRouteEncoder"
private let kLatMinEncoderString = "kLatMinEncoder"
private let kLatMaxEncoderString = "kLatMaxEncoder"
private let kLonMinEncoderString = "kLonMinEncoder"
private let kLonMaxEncoderString = "kLonMaxEncoder"


class TransitRoute: NSObject, NSCoding {
    
    var routeTag:String = ""
    var routeTitle:String = ""
    var agencyTag:String = ""
    var stopsOnRoute:[String : [TransitStop]] = [:]
    var directionTagToName:[String : String] = [:]
    var routeColor:UIColor = UIColor()
    var oppositeColor:UIColor = UIColor()
    var vehiclesOnRoute:[TransitVehicle] = []
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
    
    /**
    Returns the TransitStop object for a certain stop tag if it exists
    
    :param: stopTag Tag of the stop that will be returned
    
    :returns: Optional TransitStop object for the tag provided
    */
    func getStopForTag(stopTag:String) -> TransitStop? {
        for direction in stopsOnRoute.keys.array {
            //For each direction
            for directionStop in stopsOnRoute[direction]! {
                //For each stop in each direction
                if directionStop.stopTag == stopTag {
                    //If the stop matches, set the value to true
                    return directionStop
                }
            }
        }
        
        return nil
    }
    
    /**
    This function checks all the stops in each direction to see if a stop with a certain stop tag can be found in this route
    
    :param: stopTag the tag that is being matched against
    
    :returns: Whether the stop is in this route
    */
    func routeContainsStopWithTag(stopTag:String) -> Bool {
        return getStopForTag(stopTag) != nil
    }
    
    /**
    This function checks all the stops in each direction to see if a stop can be be found in this route
    
    :param: stop TransitStop object that is checked against all stops in the route
    
    :returns: Whether the stop is in this route
    */
    func routeContainsStop(stop:TransitStop) -> Bool {
        return routeContainsStopWithTag(stop.routeTag)
    }
    
    //MARK: NSCoding
    
    required init(coder aDecoder: NSCoder) {
        routeTag = aDecoder.decodeObjectForKey(kRouteTagEncoderString) as! String
        routeTitle = aDecoder.decodeObjectForKey(kRouteTitleEncoderString) as! String
        agencyTag = aDecoder.decodeObjectForKey(kAgencyTagEncoderString) as! String
        stopsOnRoute = aDecoder.decodeObjectForKey(kStopsOnRouteEncoderString) as! [String : [TransitStop]]
        directionTagToName = aDecoder.decodeObjectForKey(kDirectionTagToNameEncoderString) as! [String : String]
        routeColor = aDecoder.decodeObjectForKey(kRouteColorEncoderString) as! UIColor
        oppositeColor = aDecoder.decodeObjectForKey(kOppositeColorEncoderString) as! UIColor
        vehiclesOnRoute = aDecoder.decodeObjectForKey(kVehiclesOnRouteEncoderString) as! [TransitVehicle]
        latMin = aDecoder.decodeDoubleForKey(kLatMinEncoderString)
        latMax = aDecoder.decodeDoubleForKey(kLatMaxEncoderString)
        lonMin = aDecoder.decodeDoubleForKey(kLonMinEncoderString)
        lonMax = aDecoder.decodeDoubleForKey(kLonMaxEncoderString)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(routeTag, forKey: kRouteTagEncoderString)
        aCoder.encodeObject(routeTitle, forKey: kRouteTitleEncoderString)
        aCoder.encodeObject(agencyTag, forKey: kAgencyTagEncoderString)
        aCoder.encodeObject(stopsOnRoute, forKey: kStopsOnRouteEncoderString)
        aCoder.encodeObject(directionTagToName, forKey: kDirectionTagToNameEncoderString)
        aCoder.encodeObject(routeColor, forKey: kRouteColorEncoderString)
        aCoder.encodeObject(oppositeColor, forKey: kOppositeColorEncoderString)
        aCoder.encodeObject(vehiclesOnRoute, forKey: kVehiclesOnRouteEncoderString)
        aCoder.encodeDouble(latMin, forKey: kLatMinEncoderString)
        aCoder.encodeDouble(latMax, forKey: kLatMaxEncoderString)
        aCoder.encodeDouble(lonMin, forKey: kLonMinEncoderString)
        aCoder.encodeDouble(lonMax, forKey: kLonMaxEncoderString)
    }
}