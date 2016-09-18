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


open class TransitRoute: NSObject, NSCoding {
    
    open var routeTag:String = ""
    open var routeTitle:String = ""
    open var agencyTag:String = ""
    open var stopsOnRoute:[String : [TransitStop]] = [:] //[stopTag: [stop]]
    open var directionTagToName:[String : String] = [:] //[directionTag : directionName]
    open var routeColor:String = ""
    open var oppositeColor:String = ""
    
    #if os(OSX)
    public var representedRouteColor = NSColor()
    public var representedOppositeColor = NSColor()
    #else
    open var representedRouteColor = UIColor.clear
    open var representedOppositeColor = UIColor.clear
    #endif
    
    open var vehiclesOnRoute:[TransitVehicle] = []
    open var latMin:Double = 0
    open var latMax:Double = 0
    open var lonMin:Double = 0
    open var lonMax:Double = 0
    
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
    open func getRouteConfig(_ closure:@escaping (_ success:Bool, _ route:TransitRoute) -> Void) {
        let connectionHandler = SwiftBusConnectionHandler()
        connectionHandler.requestRouteConfiguration(self.routeTag, fromAgency: self.agencyTag, closure: {(route:TransitRoute?) -> Void in
            
            //If the route exists
            if let thisRoute = route {
                self.updateData(thisRoute)
                
                closure(true, self)
                
                
            } else {
                //This agency doesn't exist
                closure(false, self)
            }
        })

    }
    
    /**
    Downloads the information about vehicle locations, also gets the route config
    
    - parameter closure:    Code that is called when loading is done
        - parameter success:    Whether or not it was a success
        - parameter vehicles:   Locations of the vehicles
    */
    open func getVehicleLocations(_ closure:@escaping (_ success:Bool, _ vehicles:[TransitVehicle]) -> Void) {
        getRouteConfig({(success:Bool, route:TransitRoute) -> Void in
            if success {
                let connectionHandler = SwiftBusConnectionHandler()
                connectionHandler.requestVehicleLocationData(onRoute: self.routeTag, withAgency: self.agencyTag, closure: {(locations:[String : [TransitVehicle]]) -> Void in
                        
                    self.vehiclesOnRoute = []
                    
                    for vehiclesInDirection in locations.values {
                        self.vehiclesOnRoute += vehiclesInDirection
                    }
                    
                    //Note: If vehicles on route == [], the route isn't running
                    closure(true, self.vehiclesOnRoute)
                })
            } else {
                closure(false, [])
            }
        })
    }
    
    @available(*, deprecated: 1.2, message: "finishedLoading renamed to closure")
    open func getStopPredictionsForStop(_ stopTag:String, finishedLoading:@escaping (_ success:Bool, _ predictions:[String : [TransitPrediction]]) -> Void) {
        getStopPredictionsForStop(stopTag, closure: finishedLoading)
    }
    
    /**
    Getting the stop predictions for a certain stop
    
    - parameter stopTag:    Tag of the stop
    - parameter closure:    Code that is called when the information is done downloading
        - parameter success:        Whether or not call was a success
        - parameter predictions:    Predictions for the current stop
    */
    open func getStopPredictionsForStop(_ stopTag:String, closure:@escaping (_ success:Bool, _ predictions:[String : [TransitPrediction]]) -> Void) {
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
                        closure(true, predictions)
                    })
                } else {
                    //The stop doesn't exist
                    closure(false, [:])
                }
            } else {
                //Encountered a problem, the route probably doesn't exist or the agency isn't right
                closure(false, [:])
            }
        })
    }
    
    /**
    Returns the TransitStop object for a certain stop tag if it exists
    
    - parameter stopTag: Tag of the stop that will be returned
    
    - returns: Optional TransitStop object for the tag provided
    */
    open func getStopForTag(_ stopTag:String) -> TransitStop? {
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
    open func routeContainsStopWithTag(_ stopTag:String) -> Bool {
        return getStopForTag(stopTag) != nil
    }
    
    /**
    This function checks all the stops in each direction to see if a stop can be be found in this route
    
    - parameter stop: TransitStop object that is checked against all stops in the route
    
    - returns: Whether the stop is in this route
    */
    open func routeContainsStop(_ stop:TransitStop) -> Bool {
        return routeContainsStopWithTag(stop.routeTag)
    }
    
    //Used to update all the data after getting the route information
    fileprivate func updateData(_ newRoute:TransitRoute) {
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
        routeTag = aDecoder.decodeObject(forKey: routeTagEncoderString) as! String
        routeTitle = aDecoder.decodeObject(forKey: routeTitleEncoderString) as! String
        agencyTag = aDecoder.decodeObject(forKey: agencyTagEncoderString) as! String
        stopsOnRoute = aDecoder.decodeObject(forKey: stopsOnRouteEncoderString) as! [String : [TransitStop]]
        directionTagToName = aDecoder.decodeObject(forKey: directionTagToNameEncoderString) as! [String : String]
        routeColor = aDecoder.decodeObject(forKey: routeColorEncoderString) as! String
        oppositeColor = aDecoder.decodeObject(forKey: oppositeColorEncoderString) as! String
        #if os(OSX)
        representedRouteColor = aDecoder.decodeObjectForKey(representedRouteColorEncoderString) as! NSColor
        representedOppositeColor = aDecoder.decodeObjectForKey(representedOppositeColorEncoderString) as! NSColor
        #else
        representedRouteColor = aDecoder.decodeObject(forKey: representedRouteColorEncoderString) as! UIColor
        representedOppositeColor = aDecoder.decodeObject(forKey: representedOppositeColorEncoderString) as! UIColor
        #endif
        vehiclesOnRoute = aDecoder.decodeObject(forKey: vehiclesOnRouteEncoderString) as! [TransitVehicle]
        latMin = aDecoder.decodeDouble(forKey: latMinEncoderString)
        latMax = aDecoder.decodeDouble(forKey: latMaxEncoderString)
        lonMin = aDecoder.decodeDouble(forKey: lonMinEncoderString)
        lonMax = aDecoder.decodeDouble(forKey: lonMaxEncoderString)
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(routeTag, forKey: routeTagEncoderString)
        aCoder.encode(routeTitle, forKey: routeTitleEncoderString)
        aCoder.encode(agencyTag, forKey: agencyTagEncoderString)
        aCoder.encode(stopsOnRoute, forKey: stopsOnRouteEncoderString)
        aCoder.encode(directionTagToName, forKey: directionTagToNameEncoderString)
        aCoder.encode(routeColor, forKey: routeColorEncoderString)
        aCoder.encode(oppositeColor, forKey: oppositeColorEncoderString)
        aCoder.encode(representedRouteColor, forKey: representedRouteColorEncoderString)
        aCoder.encode(representedOppositeColor, forKey: representedOppositeColorEncoderString)
        aCoder.encode(vehiclesOnRoute, forKey: vehiclesOnRouteEncoderString)
        aCoder.encode(latMin, forKey: latMinEncoderString)
        aCoder.encode(latMax, forKey: latMaxEncoderString)
        aCoder.encode(lonMin, forKey: lonMinEncoderString)
        aCoder.encode(lonMax, forKey: lonMaxEncoderString)
    }
}
