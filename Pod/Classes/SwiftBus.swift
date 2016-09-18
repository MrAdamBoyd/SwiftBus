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

open class SwiftBus {
    open static let sharedController = SwiftBus()
    
    fileprivate var masterListTransitAgencies:[String : TransitAgency] = [:]
    
    fileprivate init() { }
    
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
    open func transitAgencies(_ closure: @escaping (_ agencies:[String : TransitAgency]) -> Void) {
        
        if masterListTransitAgencies.count > 0 {
            closure(masterListTransitAgencies)
            
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
    open func routesForAgency(_ agencyTag: String, closure: @escaping (_ agency:TransitAgency?) -> Void) {
        
        //Getting all the agencies
        transitAgencies({(innerAgencies:[String : TransitAgency]) -> Void in
            
            guard let currentAgency = innerAgencies[agencyTag] else {
                //The agency doesn't exist, return an empty dictionary
                closure(nil)
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
    open func routesForAgency(_ agencyTag: String, closure: @escaping (_ routes:[String : TransitRoute]) -> Void) {
        routesForAgency(agencyTag, closure: {(agency:TransitAgency?) -> Void in
            
            guard let currentAgency = agency else {
                //The agency doesn't exist, return an empty dictionary
                closure([:])
                return
            }
            
            closure(currentAgency.agencyRoutes)
        })
    }
    
    /**
    Gets the TransitStop object that contains a list of TransitStops in each direction and the location of each of those stops
    
    - parameter routeTag:  the route that is being looked up
    - parameter agencyTag: the agency for which the route is being looked up
    - parameter closure:   the code that gets called after the data is loaded
        - parameter route:   TransitRoute object that contains the configuration requested
    */
    open func routeConfiguration(_ routeTag: String, forAgency agencyTag: String, closure:@escaping (_ route: TransitRoute?) -> Void) {
        
        //Getting all the routes for the agency
        routesForAgency(agencyTag, closure: {(transitRoutes:[String : TransitRoute]) -> Void in
            
            guard transitRoutes[routeTag] != nil else {
                //If the route doesn't exist, return nil
                closure(nil)
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
    open func configurationForMultipleRoutes(_ routeTags: [String], forAgency agencyTag:String, closure:@escaping (_ routes:[String : TransitRoute]) -> Void) {
        var routesLoaded = 0
        var routeDictionary:[String : TransitRoute] = [:]
        
        //Going through each route tag
        for routeTag in routeTags {
            
            //Getting the route configuration
            routeConfiguration(routeTag, forAgency: agencyTag, closure: {(route: TransitRoute?) -> Void in
                
                //The route exists
                if let transitRoute = route {
                    routeDictionary[routeTag] = transitRoute
                    routesLoaded += 1
                    
                    //We have loaded all the routes, call the closure
                    if routesLoaded == routeTags.count {
                        closure(routeDictionary)
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
    open func vehicleLocationsForRoute(_ routeTag: String, forAgency agencyTag: String, closure:@escaping (_ route: TransitRoute?) -> Void) {
        
        //Getting the route configuration for the route
        routeConfiguration(routeTag, forAgency: agencyTag, closure: {(route:TransitRoute?) -> Void in
            
            guard let currentRoute = route as TransitRoute! else {
                //There's been a problem, return nil
                closure(nil)
                return
            }
                
            //Get the route configuration
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestVehicleLocationData(onRoute: routeTag, withAgency: agencyTag, closure:{(locations: [String : [TransitVehicle]]) -> Void in
                
                currentRoute.vehiclesOnRoute = []
                
                for vehiclesInDirection in locations.values {
                    currentRoute.vehiclesOnRoute += vehiclesInDirection
                }
                
                closure(currentRoute)
                
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
    open func stationPredictions(_ stopTag: String, forRoutes routeTags: [String], withAgency agencyTag: String, closure: @escaping (_ station: TransitStation?) -> Void) {
        
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
    open func stopPredictions(_ stopTag: String, onRoute routeTag: String, withAgency agencyTag: String, closure: @escaping (_ stop: TransitStop?) -> Void) {
        
        //Getting the route configuration for the route
        routeConfiguration(routeTag, forAgency: agencyTag, closure: {(route:TransitRoute?) -> Void in
            if let currentRoute = route as TransitRoute! {
                guard let currentStop = currentRoute.getStopForTag(stopTag) else {
                    //This stop isn't in the route that was provided
                    closure(nil)
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
                closure(nil)
            }
        })
    }
    
    /**
    This method clears the transitAgency dictionary from all TransitAgency objects. Because it is formatted as a tree, this clears all information for all routes and stops as well. Any function calls will download new information.
    */
    open func clearSavedData() {
        masterListTransitAgencies = [:]
    }
}
