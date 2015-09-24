//
//  TransitRoute.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation

private let routeTagEncoderString = "kRouteTagEncoder"
private let routeTitleEncoderString = "kRouteTitleEncoder"
private let agencyTagEncoderString = "kAgencyTagEncoder"
private let stopsOnRouteEncoderString = "kStopsOnRouteEncoder"
private let directionTagToNameEncoderString = "kDirectionTagToNameEncoder"
private let routeColorEncoderString = "kRouteColorEncoder"
private let oppositeColorEncoderString = "kOppositeColorEncoder"
private let representedRouteColorEncoderString = "kRepresentedRouteColorEncoder"
private let representedOppositeColorEncoderString = "kRepresentedOppositeColorEncoder"
private let vehiclesOnRouteEncoderString = "kVehiclesOnRouteEncoder"
private let latMinEncoderString = "kLatMinEncoder"
private let latMaxEncoderString = "kLatMaxEncoder"
private let lonMinEncoderString = "kLonMinEncoder"
private let lonMaxEncoderString = "kLonMaxEncoder"


public class TransitRoute: NSObject, NSCoding {
    
    public var routeTag:String = ""
    public var routeTitle:String = ""
    public var agencyTag:String = ""
    public var stopsOnRoute:[String : [TransitStop]] = [:] //[stopTag: [stop]]
    public var directionTagToName:[String : String] = [:] //[directionTag : directionName]
    public var routeColor:String = ""
    public var oppositeColor:String = ""
    
    #if os(OSX)
    public var representedRouteColor = NSColor()
    public var representedOppositeColor = NSColor()
    #else
    public var representedRouteColor = UIColor()
    public var representedOppositeColor = UIColor()
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
    
    - parameter closure: Code that is called when the route is finished loading
        - parameter success: Whether or not the downloading was a success
        - parameter route:   The route object with all the information
    */
    public func getRouteConfig(closure:(success:Bool, route:TransitRoute) -> Void) {
        let connectionHandler = SwiftBusConnectionHandler()
        connectionHandler.requestRouteConfiguration(self.routeTag, fromAgency: self.agencyTag, closure: {(route:TransitRoute?) -> Void in
            
            //If the route exists
            if let thisRoute = route {
                self.updateData(thisRoute)
                
                closure(success: true, route: self)
                
                
            } else {
                //This agency doesn't exist
                closure(success: false, route: self)
            }
        })

    }
    
    /**
    Downloads the information about vehicle locations, also gets the route config
    
    - parameter closure:    Code that is called when loading is done
        - parameter success:    Whether or not it was a success
        - parameter vehicles:   Locations of the vehicles
    */
    public func getVehicleLocations(closure:(success:Bool, vehicles:[TransitVehicle]) -> Void) {
        getRouteConfig({(success:Bool, route:TransitRoute) -> Void in
            if success {
                let connectionHandler = SwiftBusConnectionHandler()
                connectionHandler.requestVehicleLocationData(onRoute: self.routeTag, withAgency: self.agencyTag, closure: {(locations:[String : [TransitVehicle]]) -> Void in
                        
                    self.vehiclesOnRoute = []
                    
                    for vehiclesInDirection in locations.values {
                        self.vehiclesOnRoute += vehiclesInDirection
                    }
                    
                    //Note: If vehicles on route == [], the route isn't running
                    closure(success: true, vehicles: self.vehiclesOnRoute)
                })
            } else {
                closure(success: false, vehicles: [])
            }
        })
    }
    
    @available(*, deprecated=1.2, message="finishedLoading renamed to closure")
    public func getStopPredictionsForStop(stopTag:String, finishedLoading:(success:Bool, predictions:[String : [TransitPrediction]]) -> Void) {
        getStopPredictionsForStop(stopTag, closure: finishedLoading)
    }
    
    /**
    Getting the stop predictions for a certain stop
    
    - parameter stopTag:    Tag of the stop
    - parameter closure:    Code that is called when the information is done downloading
        - parameter success:        Whether or not call was a success
        - parameter predictions:    Predictions for the current stop
    */
    public func getStopPredictionsForStop(stopTag:String, closure:(success:Bool, predictions:[String : [TransitPrediction]]) -> Void) {
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
                        closure(success: true, predictions: predictions)
                    })
                } else {
                    //The stop doesn't exist
                    closure(success: false, predictions: [:])
                }
            } else {
                //Encountered a problem, the route probably doesn't exist or the agency isn't right
                closure(success: false, predictions: [:])
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
        routeTag = aDecoder.decodeObjectForKey(routeTagEncoderString) as! String
        routeTitle = aDecoder.decodeObjectForKey(routeTitleEncoderString) as! String
        agencyTag = aDecoder.decodeObjectForKey(agencyTagEncoderString) as! String
        stopsOnRoute = aDecoder.decodeObjectForKey(stopsOnRouteEncoderString) as! [String : [TransitStop]]
        directionTagToName = aDecoder.decodeObjectForKey(directionTagToNameEncoderString) as! [String : String]
        routeColor = aDecoder.decodeObjectForKey(routeColorEncoderString) as! String
        oppositeColor = aDecoder.decodeObjectForKey(oppositeColorEncoderString) as! String
        #if os(OSX)
        representedRouteColor = aDecoder.decodeObjectForKey(representedRouteColorEncoderString) as! NSColor
        representedOppositeColor = aDecoder.decodeObjectForKey(representedOppositeColorEncoderString) as! NSColor
        #else
        representedRouteColor = aDecoder.decodeObjectForKey(representedRouteColorEncoderString) as! UIColor
        representedOppositeColor = aDecoder.decodeObjectForKey(representedOppositeColorEncoderString) as! UIColor
        #endif
        vehiclesOnRoute = aDecoder.decodeObjectForKey(vehiclesOnRouteEncoderString) as! [TransitVehicle]
        latMin = aDecoder.decodeDoubleForKey(latMinEncoderString)
        latMax = aDecoder.decodeDoubleForKey(latMaxEncoderString)
        lonMin = aDecoder.decodeDoubleForKey(lonMinEncoderString)
        lonMax = aDecoder.decodeDoubleForKey(lonMaxEncoderString)
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(routeTag, forKey: routeTagEncoderString)
        aCoder.encodeObject(routeTitle, forKey: routeTitleEncoderString)
        aCoder.encodeObject(agencyTag, forKey: agencyTagEncoderString)
        aCoder.encodeObject(stopsOnRoute, forKey: stopsOnRouteEncoderString)
        aCoder.encodeObject(directionTagToName, forKey: directionTagToNameEncoderString)
        aCoder.encodeObject(routeColor, forKey: routeColorEncoderString)
        aCoder.encodeObject(oppositeColor, forKey: oppositeColorEncoderString)
        aCoder.encodeObject(representedRouteColor, forKey: representedRouteColorEncoderString)
        aCoder.encodeObject(representedOppositeColor, forKey: representedOppositeColorEncoderString)
        aCoder.encodeObject(vehiclesOnRoute, forKey: vehiclesOnRouteEncoderString)
        aCoder.encodeDouble(latMin, forKey: latMinEncoderString)
        aCoder.encodeDouble(latMax, forKey: latMaxEncoderString)
        aCoder.encodeDouble(lonMin, forKey: lonMinEncoderString)
        aCoder.encodeDouble(lonMax, forKey: lonMaxEncoderString)
    }
}