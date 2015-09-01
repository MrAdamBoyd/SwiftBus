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
    var xmlData:NSMutableData?
    var xmlString:String = ""
    var transitStop:TransitStop?
    var allAgenciesClosure:([String : TransitAgency] -> Void)?
    var allRoutesForAgencyClosure:([String : TransitRoute] -> Void)?
    var routeConfigurationClosure:(TransitRoute? -> Void)?
    
    //MARK: Requesting data
    
    func requestAllAgencies(closure: ((agencies:[String : TransitAgency]) -> Void)?) {
        xmlData = NSMutableData()
        currentRequestType = .AllAgencies
        
        allAgenciesClosure = closure
        
        startConnection(kSwiftBusAllAgenciesURL)
    }
    
    //Request data for all lines
    func requestAllRouteData(agencyTag: String, closure: ((agencyRoutes:[String : TransitRoute]) -> Void)?) {
        xmlData = NSMutableData()
        currentRequestType = .AllRoutes
        
        allRoutesForAgencyClosure = closure
        
        startConnection(kSwiftBusAllRoutesURL + agencyTag)
    }
    
    func requestRouteConfiguration(routeTag:String, fromAgency agencyTag:String, closure:((route: TransitRoute?) -> Void)?) {
        xmlData = NSMutableData()
        
        currentRequestType = .RouteConfiguration
        
        startConnection(kSwiftBusBaseURL + agencyTag + kSwiftBusRoute + routeTag)
    }
    
    func requestStopPredictionData(stop:TransitStop) {
        xmlData = NSMutableData()
        currentRequestType = .StopPredictions
        transitStop = stop
        
        var completeLinePredictionURL = kSwiftBusBaseURL + "sf-muni" + stop.routeTag + kSwiftBusStopPrediction + stop.stopTag
        var linePredictionURL = NSURL(string: completeLinePredictionURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        var linePredictionRequest = NSURLRequest(URL: linePredictionURL!)
        connection = NSURLConnection(request: linePredictionRequest, delegate: self, startImmediately: true)
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
            //Alert user via closure that something bad happened
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
    private func parseLineDefinition(xml:XMLIndexer) {
        var currentRoute:TransitRoute
        var outboundStops: [String] = []
        var inboundStops: [String] = []
        var stopDictionary: [String: TransitStop] = [:]
        var inboundTransitStops: [TransitStop] = []
        var outboundTransitStops: [TransitStop] = []
        
        
        
        var stopDirections = xml["body"]["route"]["direction"]
        
        //Getting the directions for each stop
        for stopDirection in stopDirections {
            //For each direction, inbound and outbound
            if stopDirection.element!.attributes["name"] == "Inbound" {
                //If we are looking at inbound
                for child in stopDirection.children {
                    //Go through and add the stop tags to the set of inbound tags
                    if let tag:String = child.element!.attributes["tag"] {
                        inboundStops.append(tag)
                    }
                }
            } else {
                //If we are looking at outbound
                for child in stopDirection.children {
                    //Go through and add the stop tags to the set of inbound tags
                    if let tag:String = child.element!.attributes["tag"] {
                        outboundStops.append(tag)
                    }
                }
                
            }
        }
        
        //Now we need to go through all the named stops, and add the proper direction to them
        var stops = xml["body"]["route"]["stop"]
        
        //Going through the stops and creating TransitStop objects
        for stop in stops {
            if let routeTitle = xml["body"]["route"].element!.attributes["title"], routeTag = xml["body"]["route"].element!.attributes["tag"], stopTitle = stop.element!.attributes["title"], stopTag = stop.element!.attributes["tag"] {
                let stop = TransitStop(routeTitle: routeTitle, routeTag: routeTag, stopTitle: stopTitle, stopTag: stopTag)
                //TODO: Get it working with NSColor for Mac
                
                stopDictionary[stopTag] = stop
            }
        }
        
        //Need to go through inbound and outbound stops IN ORDER and add them to an array of transit stops
        
        for stop in inboundStops {
            if let transitStop = stopDictionary[stop] as TransitStop! {
                transitStop.direction = .Inbound
                inboundTransitStops.append(transitStop)
            }
        }
        
        for stop in outboundStops {
            if let transitStop = stopDictionary[stop] as TransitStop! {
                transitStop.direction = .Outbound
                outboundTransitStops.append(transitStop)
            }
        }
        
        if let closure = routeConfigurationClosure as (TransitRoute? -> Void)! {
            closure(nil)
        }
        
    }
    
    //Parsing the information for stop predictions
    private func parseStopPredictions(xml:XMLIndexer) {
        var predictions = xml["body"]["predictions"]["direction"]
        var predictionArray:[Int] = []
        
        //Getting all predictions, only if we're using 3
        for prediction in predictions.children {
            var predictionString:String = prediction.element!.attributes["minutes"]!
            if let predictionInt = predictionString.toInt() {
                predictionArray.append(predictionInt)
            }
        }
        
        transitStop!.predictions = predictionArray
        
//        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.predictionAdded(transitStop!)
    }
    
    //MARK: NSURLConnectionDelegate
    
    private func connectionDidFinishLoading(connection: NSURLConnection) {
        
        if let finishedXML = xmlData {
            xmlString = NSString(data: finishedXML, encoding: NSUTF8StringEncoding) as! String
            let xml = SWXMLHash.parse(xmlString)
            
            switch currentRequestType {
            case .AllAgencies:
                parseAllAgenciesData(xml)
            case .AllRoutes:
                parseAllRoutesData(xml)
            case .RouteConfiguration:
                parseLineDefinition(xml)
            case .StopPredictions:
                parseStopPredictions(xml)
            default:
                println("Default")
            }
        }
    }
    
    
    //MARK: NSURLConnectionDataDelegate
    
    private func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
        xmlData?.appendData(data)
    }
}