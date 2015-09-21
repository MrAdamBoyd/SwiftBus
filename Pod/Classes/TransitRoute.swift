//
//  TransitRoute.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation

private let kRouteTagEncoderString = "kRouteTagEncoder"
private let kRouteTitleEncoderString = "kRouteTitleEncoder"
private let kAgencyTagEncoderString = "kAgencyTagEncoder"
private let kStopsOnRouteEncoderString = "kStopsOnRouteEncoder"
private let kDirectionTagToNameEncoderString = "kDirectionTagToNameEncoder"
private let kRouteColorEncoderString = "kRouteColorEncoder"
private let kOppositeColorEncoderString = "kOppositeColorEncoder"
private let kRepresentedRouteColorEncoderString = "kRepresentedRouteColorEncoder"
private let kRepresentedOppositeColorEncoderString = "kRepresentedOppositeColorEncoder"
private let kVehiclesOnRouteEncoderString = "kVehiclesOnRouteEncoder"
private let kLatMinEncoderString = "kLatMinEncoder"
private let kLatMaxEncoderString = "kLatMaxEncoder"
private let kLonMinEncoderString = "kLonMinEncoder"
private let kLonMaxEncoderString = "kLonMaxEncoder"


public class TransitRoute: NSObject, NSCoding {
    
    public var routeTag:String = ""
    public var routeTitle:String = ""
    public var agencyTag:String = ""
    public var stopsOnRoute:[String : [TransitStop]] = [:]
    public var directionTagToName:[String : String] = [:]
    public var routeColor:String = ""
    public var oppositeColor:String = ""
    
    #if os(OSX)
    public var representedRouteColor:NSColor = NSColor()
    public var representedOppositeColor:NSColor = NSColor()
    #else
    public var representedRouteColor:UIColor = UIColor()
    public var representedOppositeColor:UIColor = UIColor()
    #endif
    
    public var vehiclesOnRoute:[TransitVehicle] = []
    public var latMin:Double = 0
    public var latMax:Double = 0
    public var lonMin:Double = 0
    public var lonMax:Double = 0
    
    //Basic init
    public override init() { super.init() }
    
    //Init without stops
    public init(routeTag:String, routeTitle:String) {
        self.routeTag = routeTag
        self.routeTitle = routeTitle
    }
    
    
    /**
    Initializes the object with everything needed to get the route config
    
    - parameter routeTag:  tag of the route, eg. "5R"
    - parameter agencyTag: agency where the route is, eg. "sf-muni"
    
    - returns: None
    */
    public init(routeTag:String, agencyTag:String) {
        self.routeTag = routeTag
        self.agencyTag = agencyTag
    }
    
    /**
    Downloading the information about the route config, only need the routeTag and the agencyTag
    
    - parameter finishedLoading: Code that is called when the route is finished loading
        - parameter success: Whether or not the downloading was a success
        - parameter route:   The route object with all the information
    */
    public func getRouteConfig(finishedLoading:(success:Bool, route:TransitRoute) -> Void) {
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
    
    - parameter finishedLoading: Code that is called when loading is done
        - parameter success:     Whether or not it was a success
        - parameter vehicles:    Locations of the vehicles
    */
    public func getVehicleLocations(finishedLoading:(success:Bool, vehicles:[TransitVehicle]) -> Void) {
        getRouteConfig({(success:Bool, route:TransitRoute) -> Void in
            if success {
                let connectionHandler = SwiftBusConnectionHandler()
                connectionHandler.requestVehicleLocationData(onRoute: self.routeTag, withAgency: self.agencyTag, closure: {(locations:[String : [TransitVehicle]]) -> Void in
                        
                    self.vehiclesOnRoute = []
                    
                    //TODO: Figure out directions for vehicles
                    for vehiclesInDirection in locations.values {
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
    
    - parameter stopTag:         Tag of the stop
    - parameter finishedLoading: Code that is called when the information is done downloading
        - parameter success:     Whether or not call was a success
        - parameter predictions: Predictions for the current stop
    */
    public func getStopPredictionsForStop(stopTag:String, finishedLoading:(success:Bool, predictions:[String : [TransitPrediction]]) -> Void) {
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
    
    - parameter stopTag: Tag of the stop that will be returned
    
    - returns: Optional TransitStop object for the tag provided
    */
    public func getStopForTag(stopTag:String) -> TransitStop? {
        for direction in stopsOnRoute.keys {
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
    
    - parameter stopTag: the tag that is being matched against
    
    - returns: Whether the stop is in this route
    */
    public func routeContainsStopWithTag(stopTag:String) -> Bool {
        return getStopForTag(stopTag) != nil
    }
    
    /**
    This function checks all the stops in each direction to see if a stop can be be found in this route
    
    - parameter stop: TransitStop object that is checked against all stops in the route
    
    - returns: Whether the stop is in this route
    */
    public func routeContainsStop(stop:TransitStop) -> Bool {
        return routeContainsStopWithTag(stop.routeTag)
    }
    
    //Used to update all the data after getting the route information
    private func updateData(newRoute:TransitRoute) {
        self.routeTitle = newRoute.routeTitle
        self.stopsOnRoute = newRoute.stopsOnRoute
        self.directionTagToName = newRoute.directionTagToName
        self.routeColor = newRoute.routeColor
        self.oppositeColor = newRoute.oppositeColor
        self.representedRouteColor = newRoute.representedRouteColor
        self.representedOppositeColor = newRoute.representedOppositeColor
        self.vehiclesOnRoute = newRoute.vehiclesOnRoute
        self.latMin = newRoute.latMin
        self.latMax = newRoute.latMax
        self.lonMin = newRoute.lonMin
        self.lonMax = newRoute.lonMax
    }
    
    //MARK: NSCoding
    
    public required init(coder aDecoder: NSCoder) {
        routeTag = aDecoder.decodeObjectForKey(kRouteTagEncoderString) as! String
        routeTitle = aDecoder.decodeObjectForKey(kRouteTitleEncoderString) as! String
        agencyTag = aDecoder.decodeObjectForKey(kAgencyTagEncoderString) as! String
        stopsOnRoute = aDecoder.decodeObjectForKey(kStopsOnRouteEncoderString) as! [String : [TransitStop]]
        directionTagToName = aDecoder.decodeObjectForKey(kDirectionTagToNameEncoderString) as! [String : String]
        routeColor = aDecoder.decodeObjectForKey(kRouteColorEncoderString) as! String
        oppositeColor = aDecoder.decodeObjectForKey(kOppositeColorEncoderString) as! String
        #if os(OSX)
        representedRouteColor = aDecoder.decodeObjectForKey(kRepresentedRouteColorEncoderString) as! NSColor
        representedOppositeColor = aDecoder.decodeObjectForKey(kRepresentedOppositeColorEncoderString) as! NSColor
        #else
        representedRouteColor = aDecoder.decodeObjectForKey(kRepresentedRouteColorEncoderString) as! UIColor
        representedOppositeColor = aDecoder.decodeObjectForKey(kRepresentedOppositeColorEncoderString) as! UIColor
        #endif
        vehiclesOnRoute = aDecoder.decodeObjectForKey(kVehiclesOnRouteEncoderString) as! [TransitVehicle]
        latMin = aDecoder.decodeDoubleForKey(kLatMinEncoderString)
        latMax = aDecoder.decodeDoubleForKey(kLatMaxEncoderString)
        lonMin = aDecoder.decodeDoubleForKey(kLonMinEncoderString)
        lonMax = aDecoder.decodeDoubleForKey(kLonMaxEncoderString)
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(routeTag, forKey: kRouteTagEncoderString)
        aCoder.encodeObject(routeTitle, forKey: kRouteTitleEncoderString)
        aCoder.encodeObject(agencyTag, forKey: kAgencyTagEncoderString)
        aCoder.encodeObject(stopsOnRoute, forKey: kStopsOnRouteEncoderString)
        aCoder.encodeObject(directionTagToName, forKey: kDirectionTagToNameEncoderString)
        aCoder.encodeObject(routeColor, forKey: kRouteColorEncoderString)
        aCoder.encodeObject(oppositeColor, forKey: kOppositeColorEncoderString)
        aCoder.encodeObject(representedRouteColor, forKey: kRepresentedRouteColorEncoderString)
        aCoder.encodeObject(representedOppositeColor, forKey: kRepresentedOppositeColorEncoderString)
        aCoder.encodeObject(vehiclesOnRoute, forKey: kVehiclesOnRouteEncoderString)
        aCoder.encodeDouble(latMin, forKey: kLatMinEncoderString)
        aCoder.encodeDouble(latMax, forKey: kLatMaxEncoderString)
        aCoder.encodeDouble(lonMin, forKey: kLonMinEncoderString)
        aCoder.encodeDouble(lonMax, forKey: kLonMaxEncoderString)
    }
}