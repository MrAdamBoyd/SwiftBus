//
//  SwiftBus.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import Foundation

public class SwiftBus {
    public static let sharedController = SwiftBus()
    
    private var masterListTransitAgencies:[String : TransitAgency] = [:]
    
    private init() { }
    
    /*
    Calls that are pulled live each time
    Stop predictions
    Vehicle locations
    
    Calls that are not pulled live each time
    Agency list
    List of lines in an agency
    List of stops per line
    */
    
    /**
    Gets the list of agencies from the nextbus API or what is already in memory if getAgencies has been called before
    
    agencies.keys.array will return a list of the keys used
    agencies.values.array will return a list of TransitAgencies
    
    - parameter closure: Code that is called after the dictionary of agencies has loaded
        - parameter agencies:    Dictionary of agencyTags to TransitAgency objects
    */
    public func transitAgencies(closure: (agencies:[String : TransitAgency]) -> Void) {
        
        if masterListTransitAgencies.count > 0 {
            closure(agencies: masterListTransitAgencies)
            
        } else {
            //We need to load the transit agency data
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestAllAgencies({(agencies:[String : TransitAgency]) -> Void in
                //Insert this closure around the inner one because the agencies need to be saved
                self.masterListTransitAgencies = agencies

                closure(agencies: agencies)
            })
            
        }
    }
    
    /**
    Gets the TransitRoutes for a particular agency. If the list of agencies hasn't been downloaded, this functions gets them first
    
    - parameter agencyTag: Tag of the agency
    - parameter closure:   Code that is called after everything has loaded
        - parameter agency:  Optional TransitAgency object that contains the routes
    */
    public func routesForAgency(agencyTag: String, closure: (agency:TransitAgency?) -> Void) {
        
        //Getting all the agencies
        transitAgencies({(innerAgencies:[String : TransitAgency]) -> Void in
            
            guard let currentAgency = innerAgencies[agencyTag] else {
                //The agency doesn't exist, return an empty dictionary
                closure(agency: nil)
                return
            }
                
            //The agency exists & we need to load the transit agency data
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestAllRouteData(agencyTag, closure: {(agencyRoutes:[String : TransitRoute]) -> Void in
                
                //Adding the agency to the route
                for route in agencyRoutes.values {
                    route.agencyTag = agencyTag
                }
                
                //Saving the routes for the agency
                currentAgency.agencyRoutes = agencyRoutes
                
                //Return the transitRoutes for the agency
                closure(agency: currentAgency)
            })
        })

    }
    
    /**
    Gets the TransitRoutes for a particular agency. If the list of agencies hasn't been downloaded, this functions gets them first
    
    - parameter agencyTag: the transit agency that this will download the routes for
    - parameter closure:   Code that is called after all the data has loaded
        - parameter routes:  Dictionary of routeTags to TransitRoute objects
    */
    public func routesForAgency(agencyTag: String, closure: (routes:[String : TransitRoute]) -> Void) {
        routesForAgency(agencyTag, closure: {(agency:TransitAgency?) -> Void in
            
            guard let currentAgency = agency else {
                //The agency doesn't exist, return an empty dictionary
                closure(routes: [:])
                return
            }
            
            closure(routes: currentAgency.agencyRoutes)
        })
    }
    
    /**
    Gets the TransitStop object that contains a list of TransitStops in each direction and the location of each of those stops
    
    - parameter routeTag:  the route that is being looked up
    - parameter agencyTag: the agency for which the route is being looked up
    - parameter closure:   the code that gets called after the data is loaded
        - parameter route:   TransitRoute object that contains the configuration requested
    */
    public func routeConfiguration(routeTag: String, forAgency agencyTag: String, closure:(route: TransitRoute?) -> Void) {
        
        //Getting all the routes for the agency
        routesForAgency(agencyTag, closure: {(transitRoutes:[String : TransitRoute]) -> Void in
            
            guard transitRoutes[routeTag] != nil else {
                //If the route doesn't exist, return nil
                closure(route: nil)
                return
            }
            
            //If the route exists, get the route configuration
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestRouteConfiguration(routeTag, fromAgency: agencyTag, closure: {(route:TransitRoute?) -> Void in
                
                //If there were no problems getting the route
                if let transitRoute = route as TransitRoute! {
                    
                    //Applying agencyTag to all TransitStop subelements
                    for routeDirection in transitRoute.stopsOnRoute.values {
                        for stop in routeDirection {
                            stop.agencyTag = agencyTag
                        }
                    }
                    
                    self.masterListTransitAgencies[agencyTag]?.agencyRoutes[routeTag] = transitRoute
                    
                    //Call the closure
                    closure(route: transitRoute)
                    
                } else {
                    //There was a problem, return nil
                    closure(route: nil)
                }
            })
            
        })
    }
    
    /**
    Gets the route configuration for all routeTags provided. All routes must come from the same agency
    
    - parameter routeTags: array of routes that will be looked up
    - parameter agencyTag: the agency for which the route is being looked up
    - parameter closure:   the code that gets called after all routes have been loaded
        - parameter routes: dictionary of TransitRoute objects. Objects can be accessed with routes[routeTag]
    */
    public func configurationForMultipleRoutes(routeTags: [String], forAgency agencyTag:String, closure:(routes:[String : TransitRoute]) -> Void) {
        var routesLoaded = 0
        var routeDictionary:[String : TransitRoute] = [:]
        
        //Going through each route tag
        for routeTag in routeTags {
            
            //Getting the route configuration
            routeConfiguration(routeTag, forAgency: agencyTag, closure: {(route: TransitRoute?) -> Void in
                
                //The route exists
                if let transitRoute = route {
                    routeDictionary[routeTag] = transitRoute
                    routesLoaded++
                    
                    //We have loaded all the routes, call the closure
                    if routesLoaded == routeTags.count {
                        closure(routes: routeDictionary)
                    }
                }
            })
        }
    }
    
    /**
    Gets the vehicle locations for a particular route
    
    - parameter routeTag:  Tag of the route we are looking at
    - parameter agencyTag: Tag of the agency where the line is
    - parameter closure:   Code that gets called after the call has completed
        - parameter route:   Optional TransitRoute object that contains the vehicle locations
    */
    public func vehicleLocationsForRoute(routeTag: String, forAgency agencyTag: String, closure:(route: TransitRoute?) -> Void) {
        
        //Getting the route configuration for the route
        routeConfiguration(routeTag, forAgency: agencyTag, closure: {(route:TransitRoute?) -> Void in
            
            guard let currentRoute = route as TransitRoute! else {
                //There's been a problem, return nil
                closure(route: nil)
                return
            }
                
            //Get the route configuration
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestVehicleLocationData(onRoute: routeTag, withAgency: agencyTag, closure:{(locations: [String : [TransitVehicle]]) -> Void in
                
                currentRoute.vehiclesOnRoute = []
                
                //TODO: Figure out directions for vehicles
                for vehiclesInDirection in locations.values {
                    currentRoute.vehiclesOnRoute += vehiclesInDirection
                }
                
                closure(route: currentRoute)
                
            })
                
        })
    }
    
    /**
    Returns the predictions for a certain stop on a route, returns nil if the stop isn't on the route, also gets all the messages for that stop
    
    - parameter stopTag:   Tag of the stop
    - parameter routeTags: Tags of the routes that serve the stop
    - parameter agencyTag: Tag of the agency
    - parameter closure:   Code that is called after the result is gotten, route will be nil if stop doesn't exist
        - parameter stop:    Optional TransitStation that contains the predictions
    */
    public func stationPredictions(stopTag: String, forRoutes routeTags: [String], withAgency agencyTag: String, closure: (station: TransitStation?) -> Void) {
        
        //Getting the configuration for all routes
        configurationForMultipleRoutes(routeTags, forAgency: agencyTag, closure: {(routes:[String : TransitRoute]) -> Void in
            
            //Only use the routes that exist
            let existingRoutes = Array(routes.keys)
            
            //Get the predictions
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestStationPredictionData(stopTag, forRoutes: existingRoutes, withAgency: agencyTag, closure: {(predictions:[String :[String : [TransitPrediction]]]) -> Void in
                
                let currentStation = TransitStation()
                currentStation.stopTag = stopTag
                currentStation.agencyTag = agencyTag
                currentStation.routesAtStation = Array(routes.values)
                currentStation.stopTitle = Array(routes.values)[0].getStopForTag(stopTag)!.stopTitle //Safe, we know all these exist
                currentStation.predictions = predictions
                
                //Saving the predictions in the TransitStop objects for all TransitRoutes
                for route in routes.values {
                    if let stop = route.getStopForTag(stopTag) {
                        stop.predictions = predictions[route.routeTag]!
                    }
                }
                
                closure(station: currentStation)
                
            })
        })
    }
    
    /**
    Returns the predictions for a certain stop on a route, returns nil if the stop isn't on the route, also gets all the messages for that stop
    
    - parameter stopTag:   Tag of the stop
    - parameter routeTag:  Tag of the route
    - parameter agencyTag: Tag of the agency
    - parameter closure:   Code that is called after the result is gotten, route will be nil if stop doesn't exist
        - parameter stop:    Optional TransitStop object that contains the predictions
    */
    public func stopPredictions(stopTag: String, onRoute routeTag: String, withAgency agencyTag: String, closure: (stop: TransitStop?) -> Void) {
        
        //Getting the route configuration for the route
        routeConfiguration(routeTag, forAgency: agencyTag, closure: {(route:TransitRoute?) -> Void in
            if let currentRoute = route as TransitRoute! {
                guard let currentStop = currentRoute.getStopForTag(stopTag) else {
                    //This stop isn't in the route that was provided
                    closure(stop: nil)
                    return
                }
                
                //Get the route configuration
                let connectionHandler = SwiftBusConnectionHandler()
                connectionHandler.requestStopPredictionData(stopTag, onRoute: routeTag, withAgency: agencyTag, closure: {(predictions:[String : [TransitPrediction]], messages:[String]) -> Void in
                    
                    currentStop.predictions = predictions
                    currentStop.messages = messages
                    
                    //Call the closure
                    closure(stop: currentStop)
                    
                })
                    
            } else {
                //There's been a problem, return nil
                closure(stop: nil)
            }
        })
    }
    
    /**
    This method clears the transitAgency dictionary from all TransitAgency objects. Because it is formatted as a tree, this clears all information for all routes and stops as well. Any function calls will download new information.
    */
    public func clearSavedData() {
        masterListTransitAgencies = [:]
    }
}