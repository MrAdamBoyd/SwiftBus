//
//  ConnectionHandler.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 com.adam. All rights reserved.
//

import Foundation
import SWXMLHash

enum RequestType:Int {
    case NoRequest = 0, AllAgencies, AllRoutes, RouteConfiguration, StopPredictions
}

class ConnectionHandler: NSObject, NSURLConnectionDataDelegate {
    private var currentRequestType:RequestType = .NoRequest
    private var connection:NSURLConnection?
    var xmlData:NSMutableData = NSMutableData()
    var xmlString:String = ""
    var allAgenciesClosure:([String : TransitAgency] -> Void)?
    var allRoutesForAgencyClosure:([String : TransitRoute] -> Void)?
    var routeConfigClosure:(TransitRoute? -> Void)?
    var stopPredictionsClosure:([String : [Int]] -> Void)?
    
    //MARK: Requesting data
    
    func requestAllAgencies(closure: ((agencies:[String : TransitAgency]) -> Void)?) {
        currentRequestType = .AllAgencies
        
        allAgenciesClosure = closure
        
        startConnection(kSwiftBusAllAgenciesURL)
    }
    
    //Request data for all lines
    func requestAllRouteData(agencyTag: String, closure: ((agencyRoutes:[String : TransitRoute]) -> Void)?) {
        currentRequestType = .AllRoutes
        
        allRoutesForAgencyClosure = closure
        
        startConnection(kSwiftBusAllRoutesURL + agencyTag)
    }
    
    func requestRouteConfiguration(routeTag:String, fromAgency agencyTag:String, closure:((route: TransitRoute?) -> Void)?) {
        currentRequestType = .RouteConfiguration
        
        routeConfigClosure = closure
        
        startConnection(kSwiftBusRouteConfigURL + agencyTag + kSwiftBusRoute + routeTag)
    }
    
    func requestStopPredictionData(stopTag:String, onRoute routeTag:String, withAgency agencyTag:String, closure:((predictions: [String : [Int]]) -> Void)?) {
        currentRequestType = .StopPredictions
        
        stopPredictionsClosure = closure
        
        startConnection(kSwiftBusStopPredictionsURL + agencyTag + kSwiftBusRoute + routeTag + kSwiftBusStop + stopTag)
    }
    
    /**
    This is the method that all other request methods call in order to create the URL & start downloading data via an NSURLConnection
    
    :param: requestURL string of the url that is being requested
    */
    private func startConnection(requestURL:String) {
        var optionalURL:NSURL? = NSURL(string: requestURL)
        
        if let url = optionalURL as NSURL! {
            var urlRequest:NSURLRequest = NSURLRequest(URL: url)
            connection = NSURLConnection(request: urlRequest, delegate: self, startImmediately: true)
        } else {
            //TODO: Alert user via closure that something bad happened
        }
    }
    
    //MARK: Parsing methods
    
    
    /**
    Creating all the transit agencies from the xml, calls the allAgenciesClosure when done
    
    :param: xml xml gotten from calling NextBus's API
    */
    private func parseAllAgenciesData(xml:XMLIndexer) {
        let agenciesXML:[XMLIndexer] = xml["body"].children
        var transitAgencies:[String : TransitAgency] = [:]
        
        //Creating all the agencies
        for agencyXML:XMLIndexer in agenciesXML {
            
            //If all the proper elements exist
            if let agencyTag = agencyXML.element!.attributes["tag"], agencyTitle = agencyXML.element!.attributes["title"], agencyRegion = agencyXML.element!.attributes["regionTitle"] {
                
                var newAgency:TransitAgency = TransitAgency(agencyTag: agencyTag, agencyTitle: agencyTitle, agencyRegion: agencyRegion)
                
                //Some agencies have a shortTitle
                if let agencyShortTitle = agencyXML.element!.attributes["shortTitle"] {
                    newAgency.agencyShortTitle = agencyShortTitle
                }
                
                transitAgencies[agencyTag] = newAgency
            }
            
        }
        
        if let closure = allAgenciesClosure as ([String : TransitAgency] -> Void)! {
            closure(transitAgencies)
        }
    }
    
    /**
    Creating all the TransitRoutes from the xml, calls allRoutesForAgencyClosure when done
    
    :param: xml XML gotten from NextBus's API
    */
    private func parseAllRoutesData(xml:XMLIndexer) {
        var transitRoutes:[String : TransitRoute] = [:]
        
        //Going through all lines and saving them
        for child in xml["body"].children {
            
            if let routeTag = child.element!.attributes["tag"], routeTitle = child.element!.attributes["title"] {
                //If we can create all the routes
                var currentRoute:TransitRoute = TransitRoute(routeTag: routeTag, routeTitle: routeTitle)
                transitRoutes[routeTag] = currentRoute
            }
        }
        
        if let closure = allRoutesForAgencyClosure as ([String : TransitRoute] -> Void)! {
            closure(transitRoutes)
        }
    }
    
    //Parsing the line definition
    private func parseRouteConfiguration(xml:XMLIndexer) {
        var currentRoute:TransitRoute = TransitRoute()
        var outboundStops: [String] = []
        var inboundStops: [String] = []
        var stopDirectionDict: [String : [String]] = [:]
        var allStopsDictionary: [String : TransitStop] = [:]
        var inboundTransitStops: [TransitStop] = []
        var outboundTransitStops: [TransitStop] = []
        
        var routeConfig:[String : String] = xml["body"]["route"].element!.attributes
        
        //Creating the route from the current information
        if let routeTag = routeConfig["tag"], routeTitle = routeConfig["title"], latMin = routeConfig["latMin"], latMax = routeConfig["latMax"], lonMin = routeConfig["lonMin"], lonMax = routeConfig["lonMax"], routeColorHex = routeConfig["color"], oppositeColorHex = routeConfig["oppositeColor"] {
            currentRoute.routeTag = routeTag
            currentRoute.routeTitle = routeTitle
            currentRoute.latMin = (latMin as NSString).doubleValue
            currentRoute.latMax = (latMax as NSString).doubleValue
            currentRoute.lonMin = (lonMin as NSString).doubleValue
            currentRoute.lonMax = (lonMax as NSString).doubleValue
            currentRoute.routeColor = UIColor(hex: "#" + routeColorHex)
            currentRoute.oppositeColor = UIColor(hex: "#" + oppositeColorHex)
        }
        
        var stopDirections:XMLIndexer = xml["body"]["route"]["direction"]
        
        for stopDirection in stopDirections {
            //For each direction, eg. "Inbound to downtown", "Inbound to Caltrain", "Outbound to Ocean Beach"
            if let currentDirection:String = stopDirection.element!.attributes["title"] {
                
                stopDirectionDict[currentDirection] = []
                
                for child in stopDirection.children {
                    //For each stop per direction
                
                    if let tag:String = child.element!.attributes["tag"] {
                        stopDirectionDict[currentDirection]?.append(tag)
                    }
                    
                }
                
            }
        }
        
        //Now we need to go through all the named stops, and add the proper direction to them
        var stops = xml["body"]["route"]["stop"]
        
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
        
        if let closure = routeConfigClosure as (TransitRoute? -> Void)! {
            closure(currentRoute)
        }
        
    }
    
    //Parsing the information for stop predictions
    private func parseStopPredictions(xml:XMLIndexer) {
        var predictions = xml["body"]["predictions"]
        var predictionArray:[Int] = []
        var predictionDict:[String:[Int]] = [:]
        
        //Getting all the predictions
        for predictionDirection in predictions.children {
            
            //Getting the direction name
            if let directionName = predictionDirection.element!.attributes["title"] {
                
                predictionDict[directionName] = []
                
                for prediction in predictionDirection.children {
                    //Getting each individual prediction in minutes
                    var predictionString:String = prediction.element!.attributes["minutes"]!
                    if let predictionInt = predictionString.toInt() {
                        predictionDict[directionName]?.append(predictionInt)
                    }
                }
            }
            
        }
        
        if let closure = stopPredictionsClosure as ([String:[Int]] -> Void)! {
            closure(predictionDict)
        }
        
//        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.predictionAdded(transitStop!)
    }
    
    //MARK: NSURLConnectionDelegate
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        xmlString = NSString(data: xmlData, encoding: NSUTF8StringEncoding) as! String
        let xml = SWXMLHash.parse(xmlString)
        
        switch currentRequestType {
        case .AllAgencies:
            parseAllAgenciesData(xml)
        case .AllRoutes:
            parseAllRoutesData(xml)
        case .RouteConfiguration:
            parseRouteConfiguration(xml)
        case .StopPredictions:
            parseStopPredictions(xml)
        default:
            println("Default")
        }
    }
    
    
    //MARK: NSURLConnectionDataDelegate
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
        xmlData.appendData(data)
    }
}