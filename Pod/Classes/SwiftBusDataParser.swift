//
//  SwiftBusParser.swift
//  Pods
//
//  Created by Adam on 2015-09-21.
//
//

import Foundation
import SWXMLHash

class SwiftBusDataParser: NSObject {
    
    /**
    Creating all the transit agencies from the xml, calls the allAgenciesClosure when done
    
    - parameter xml:    xml gotten from calling NextBus's API
    - parameter closure:code that gets called when fetch of information is complete
    */
    func parseAllAgenciesData(xml:XMLIndexer, closure: (agencies:[String : TransitAgency]) -> Void) {
        let agenciesXML:[XMLIndexer] = xml["body"].children
        var transitAgencies:[String : TransitAgency] = [:]
        
        //Creating all the agencies
        for agencyXML:XMLIndexer in agenciesXML {
            
            //If all the proper elements exist
            if let agencyTag = agencyXML.element!.attributes["tag"], agencyTitle = agencyXML.element!.attributes["title"], agencyRegion = agencyXML.element!.attributes["regionTitle"] {
                
                let newAgency:TransitAgency = TransitAgency(agencyTag: agencyTag, agencyTitle: agencyTitle, agencyRegion: agencyRegion)
                
                //Some agencies have a shortTitle
                if let agencyShortTitle = agencyXML.element!.attributes["shortTitle"] {
                    newAgency.agencyShortTitle = agencyShortTitle
                }
                
                transitAgencies[agencyTag] = newAgency
            }
            
        }
        
        closure(agencies: transitAgencies)
    }
    
    /**
    Creating all the TransitRoutes from the xml, calls allRoutesForAgencyClosure when done
    
    - parameter xml:    XML gotten from NextBus's API
    - parameter closure:code that gets called when fetch of information is complete
    */
    func parseAllRoutesData(xml:XMLIndexer, closure: (agencyRoutes:[String : TransitRoute]) -> Void) {
        var transitRoutes:[String : TransitRoute] = [:]
        
        //Going through all lines and saving them
        for child in xml["body"].children {
            
            if let routeTag = child.element!.attributes["tag"], routeTitle = child.element!.attributes["title"] {
                //If we can create all the routes
                let currentRoute:TransitRoute = TransitRoute(routeTag: routeTag, routeTitle: routeTitle)
                transitRoutes[routeTag] = currentRoute
            }
        }
        
        closure(agencyRoutes: transitRoutes)
    }
    
    /**
    Parsing the route configuration data
    
    - parameter xml:    XML gotten from NextBus's API
    - parameter closure:code that gets called when fetch of information is complete
    */
    func parseRouteConfiguration(xml:XMLIndexer, closure:(route: TransitRoute?) -> Void) {
        let currentRoute = TransitRoute()
        var stopDirectionDict: [String : [String]] = [:]
        var allStopsDictionary: [String : TransitStop] = [:]
        
        var routeConfig:[String : String] = xml["body"]["route"].element!.attributes
        
        //Creating the route from the current information
        guard let routeTag = routeConfig["tag"], routeTitle = routeConfig["title"], latMin = routeConfig["latMin"], latMax = routeConfig["latMax"], lonMin = routeConfig["lonMin"], lonMax = routeConfig["lonMax"], routeColorHex = routeConfig["color"], oppositeColorHex = routeConfig["oppositeColor"] else {
            //Couldn't get the route information, return
            closure(route: currentRoute)
            return
        }
        
        currentRoute.routeTag = routeTag
        currentRoute.routeTitle = routeTitle
        currentRoute.latMin = (latMin as NSString).doubleValue
        currentRoute.latMax = (latMax as NSString).doubleValue
        currentRoute.lonMin = (lonMin as NSString).doubleValue
        currentRoute.lonMax = (lonMax as NSString).doubleValue
        currentRoute.routeColor = routeColorHex
        currentRoute.oppositeColor = oppositeColorHex
        #if os(OSX)
        currentRoute.representedRouteColor = NSColor(rgba: "#" + routeColorHex)
        currentRoute.representedOppositeColor = NSColor(rgba: "#" + oppositeColorHex)
        #else
        currentRoute.representedRouteColor = UIColor(rgba: "#" + routeColorHex)
        currentRoute.representedOppositeColor = UIColor(rgba: "#" + oppositeColorHex)
        #endif
        
        let stopDirections:XMLIndexer = xml["body"]["route"]["direction"]
        
        for stopDirection in stopDirections {
            //For each direction, eg. "Inbound to downtown", "Inbound to Caltrain", "Outbound to Ocean Beach"
            if let currentDirection:String = stopDirection.element!.attributes["title"], directionTag:String = stopDirection.element!.attributes["tag"] {
                
                stopDirectionDict[currentDirection] = []
                currentRoute.directionTagToName[directionTag] = currentDirection
                
                for child in stopDirection.children {
                    //For each stop per direction
                    
                    if let tag:String = child.element!.attributes["tag"] {
                        stopDirectionDict[currentDirection]?.append(tag)
                    }
                    
                }
                
            }
        }
        
        //Now we need to go through all the named stops, and add the proper direction to them
        let stops = xml["body"]["route"]["stop"]
        
        //Going through the stops and creating TransitStop objects
        for stop in stops {
            if let routeTitle = xml["body"]["route"].element!.attributes["title"], routeTag = xml["body"]["route"].element!.attributes["tag"], stopTitle = stop.element!.attributes["title"], stopTag = stop.element!.attributes["tag"], stopLat = stop.element!.attributes["lat"], stopLon = stop.element!.attributes["lon"] {
                let stop = TransitStop(routeTitle: routeTitle, routeTag: routeTag, stopTitle: stopTitle, stopTag: stopTag)
                stop.lat = (stopLat as NSString).doubleValue
                stop.lon = (stopLon as NSString).doubleValue
                
                allStopsDictionary[stopTag] = stop
            }
        }
        
        //Going through all stops IN ORDER and add them to an array of transit stops
        for stopDirection in stopDirectionDict.keys {
            //For each direction
            
            currentRoute.stopsOnRoute[stopDirection] = []
            
            for stopTag in stopDirectionDict[stopDirection]! {
                //For each stop per direction
                
                if let transitStop = allStopsDictionary[stopTag] {
                    //Getting the stop from the dictionary of all stops and adding it to the correct direction for the current TransitRoute
                    transitStop.direction = stopDirection
                    currentRoute.stopsOnRoute[stopDirection]!.append(transitStop)
                }
            }
            
        }
        
        closure(route: currentRoute)
    }
    
    /**
    Parsing the vehicle location data
    
    - parameter xml:    XML gotten from NextBus's API
    - parameter closure:code that gets called when fetch of information is complete
    */
    func parseVehicleLocations(xml:XMLIndexer, closure:(locations:[String : [TransitVehicle]]) -> Void) {
        let vehicles = xml["body"]
        var dictionaryOfVehicles:[String : [TransitVehicle]] = [:]
        
        for vehicle in vehicles.children {
            let attributes = vehicle.element!.attributes
            
            if let vehicleID = attributes["id"], directionTag = attributes["dirTag"], lat = attributes["lat"], lon = attributes["lon"], secondsSinceLastReport = attributes["secsSinceReport"], heading = attributes["heading"], speedKmH = attributes["speedKmHr"] {
                //If all the proper attributes exist
                let newVehicle = TransitVehicle(vehicleID: vehicleID, directionTag: directionTag, lat: lat, lon: lon, secondsSinceReport: secondsSinceLastReport, heading: heading, speedKmH: speedKmH)
                
                //If there is a leading vehicle
                if let leadingVehicleId = attributes["leadingVehicleId"] {
                    newVehicle.leadingVehicleId = Int(leadingVehicleId)!
                }
                
                //Adding newVehicle to the dictionary if it hasn't been created
                if dictionaryOfVehicles[directionTag] == nil {
                    dictionaryOfVehicles[directionTag] = [newVehicle]
                } else {
                    dictionaryOfVehicles[directionTag]?.append(newVehicle)
                }
                
            }
        }
        
        closure(locations: dictionaryOfVehicles)
    }
    
    func parseStationPredictions(xml:XMLIndexer, closure:(predictions: [String : [TransitPrediction]], messages:[String]) -> Void) {
        let predictions = xml["body"]
        
        
        for predictionDirection in predictions.children {
            print(predictionDirection.element!.attributes["routeTitle"])
        }
    }
    
    /**
    Parsing the stop prediction data
    
    - parameter xml:    XML gotten from NextBus's API
    - parameter closure:code that gets called when fetch of information is complete
    */
    func parseStopPredictions(xml:XMLIndexer, closure:(predictions: [String : [TransitPrediction]], messages:[String]) -> Void) {
        let predictions = xml["body"]["predictions"]
        var predictionDict:[String : [TransitPrediction]] = [:]
        var messageArray:[String] = []
        
        //Getting all the predictions
        for predictionDirection in predictions.children {
            
            //Getting the direction name
            if let directionName = predictionDirection.element!.attributes["title"] {
                
                predictionDict[directionName] = []
                
                for prediction in predictionDirection.children {
                    //Getting each individual prediction in minutes
                    
                    if let numberOfVechiles = Int((prediction.element?.attributes["vehiclesInConsist"])!),predictionInMinutes = Int((prediction.element?.attributes["minutes"])!), predictionInSeconds = Int((prediction.element?.attributes["seconds"])!), vehicleTag = Int((prediction.element?.attributes["vehicle"])!) {
                        //If all the elements exist
                        
                        let newPrediction = TransitPrediction(numberOfVehicles: numberOfVechiles, predictionInMinutes: predictionInMinutes, predictionInSeconds: predictionInSeconds, vehicleTag: vehicleTag)
                        
                        predictionDict[directionName]?.append(newPrediction)
                    }
                }
            }
        }
        
        let messages = predictions["message"]
        
        for message in messages {
            //Going through the messages and adding them
            if let messageTitle = message.element!.attributes["text"] {
                messageArray.append(messageTitle)
            }
        }
    
        closure(predictions: predictionDict, messages: messageArray)
    }
}