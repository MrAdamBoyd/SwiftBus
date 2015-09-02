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
    Initializes the object with everything needed to get the route config
    
    :param: routeTag  tag of the route, eg. "5R"
    :param: agencyTag agency where the route is, eg. "sf-muni"
    
    :returns: None
    */
    init(routeTag:String, agencyTag:String) {
        self.routeTag = routeTag
        self.agencyTag = agencyTag
    }
    
    /**
    Downloading the information about the route config, only need the routeTag and the agencyTag
    
    :param: finishedLoading Code that is called when the route is finished loading
        :param: success Whether or not the downloading was a success
        :param: route   The route object with all the information
    */
    func getRouteConfig(finishedLoading:(success:Bool, route:TransitRoute) -> Void) {
        let connectionHandler = SwiftBusConnectionHandler()
        connectionHandler.requestRouteConfiguration(self.routeTag, fromAgency: self.agencyTag, closure: {(route:TransitRoute?) -> Void in
            
            //If the route exists
            if let thisRoute = route {
                self.updateData(thisRoute)
                
                finishedLoading(success: true, route: self)
                
                
            } else {
                //This agency doesn't exist
                finishedLoading(success: false, route: self)
            }
        })

    }
    
    /**
    Downloads the information about vehicle locations, also gets the route config
    
    :param: finishedLoading Code that is called when loading is done
        :param: success     Whether or not it was a success
        :param: vehicles    Locations of the vehicles
    */
    func getVehicleLocations(finishedLoading:(success:Bool, vehicles:[TransitVehicle]) -> Void) {
        getRouteConfig({(success:Bool, route:TransitRoute) -> Void in
            if success {
                let connectionHandler = SwiftBusConnectionHandler()
                connectionHandler.requestVehicleLocationData(onRoute: self.routeTag, withAgency: self.agencyTag, closure: {(locations:[String : [TransitVehicle]]) -> Void in
                        
                    self.vehiclesOnRoute = []
                    
                    //TODO: Figure out directions for vehicles
                    for vehiclesInDirection in locations.values.array {
                        self.vehiclesOnRoute += vehiclesInDirection
                    }
                    
                    //Note: If vehicles on route == [], the route isn't running
                    finishedLoading(success: true, vehicles: self.vehiclesOnRoute)
                })
            } else {
                finishedLoading(success: false, vehicles: [])
            }
        })
    }
    
    /**
    Getting the stop predictions for a certain stop
    
    :param: stopTag         Tag of the stop
    :param: finishedLoading Code that is called when the information is done downloading
    :param: predictions
    */
    func getStopPredictionsForStop(stopTag:String, finishedLoading:(success:Bool, predictions:[String : [TransitPrediction]]) -> Void) {
        getRouteConfig({(success:Bool, route:TransitRoute) -> Void in
            if success {
                //Everything should be fine
                if let stop = self.getStopForTag(stopTag) {
                    
                    let connectionHandler = SwiftBusConnectionHandler()
                    connectionHandler.requestStopPredictionData(stopTag, onRoute: self.routeTag, withAgency: self.agencyTag, closure: {(predictions:[String : [TransitPrediction]], messages:[String]) -> Void in
                        
                        //Saving the messages and predictions
                        stop.predictions = predictions
                        stop.messages = messages
                        
                        //Finished loading, send back
                        finishedLoading(success: true, predictions: predictions)
                    })
                } else {
                    //The stop doesn't exist
                    finishedLoading(success: false, predictions: [:])
                }
            } else {
                //Encountered a problem, the route probably doesn't exist or the agency isn't right
                finishedLoading(success: false, predictions: [:])
            }
        })
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
    
    //Used to update all the data after getting the route information
    private func updateData(newRoute:TransitRoute) {
        self.routeTitle = newRoute.routeTitle
        self.stopsOnRoute = newRoute.stopsOnRoute
        self.directionTagToName = newRoute.directionTagToName
        self.routeColor = newRoute.routeColor
        self.oppositeColor = newRoute.oppositeColor
        self.vehiclesOnRoute = newRoute.vehiclesOnRoute
        self.latMin = newRoute.latMin
        self.latMax = newRoute.latMax
        self.lonMin = newRoute.lonMin
        self.lonMax = newRoute.lonMax
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