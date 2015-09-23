//
//  ConnectionHandler.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation
import SWXMLHash

enum RequestType:Int {
    case NoRequest = 0, AllAgencies, AllRoutes, RouteConfiguration, StopPredictions, StationPredictions, VehicleLocations
}

class SwiftBusConnectionHandler: NSObject, NSURLConnectionDataDelegate {
    
    var currentRequestType:RequestType = .NoRequest
    var connection:NSURLConnection?
    var xmlData = NSMutableData()
    var xmlString:String = ""
    var allAgenciesClosure:([String : TransitAgency] -> Void)!
    var allRoutesForAgencyClosure:([String : TransitRoute] -> Void)!
    var routeConfigClosure:(TransitRoute? -> Void)!
    var stationPredictionsClosure:(([String : [String : [TransitPrediction]]]) -> Void)!
    var stopPredictionsClosure:(([String : [TransitPrediction]], [String]) -> Void)!
    var vehicleLocationsClosure:([String : [TransitVehicle]] -> Void)!
    
    //MARK: Requesting data
    
    func requestAllAgencies(closure: (agencies:[String : TransitAgency]) -> Void) {
        currentRequestType = .AllAgencies
        
        allAgenciesClosure = closure
        
        startConnection(allAgenciesURL)
    }
    
    //Request data for all lines
    func requestAllRouteData(agencyTag: String, closure: (agencyRoutes:[String : TransitRoute]) -> Void) {
        currentRequestType = .AllRoutes
        
        allRoutesForAgencyClosure = closure
        
        startConnection(allRoutesURL + agencyTag)
    }
    
    func requestRouteConfiguration(routeTag:String, fromAgency agencyTag:String, closure:(route: TransitRoute?) -> Void) {
        currentRequestType = .RouteConfiguration
        
        routeConfigClosure = closure
        
        startConnection(routeConfigURL + agencyTag + routeURLSegment + routeTag)
    }
    
    func requestVehicleLocationData(onRoute routeTag:String, withAgency agencyTag:String, closure:(locations:[String : [TransitVehicle]]) -> Void) {
        currentRequestType = .VehicleLocations
        
        vehicleLocationsClosure = closure
        
        startConnection(vehicleLocationsURL + agencyTag + routeURLSegment + routeTag)
    }
    
    func requestStationPredictionData(stopTag: String, forRoutes routeTags:[String], withAgency agencyTag:String, closure: (predictions: [String : [String : [TransitPrediction]]]) -> Void) {
        currentRequestType = .StationPredictions
        
        stationPredictionsClosure = closure
        
        //Building the multi stop url
        var multiplePredictionString = multiplePredictionsURL + agencyTag
        for tag in routeTags {
            multiplePredictionString += multiStopURLSegment + tag + "|" + stopTag
        }
        
        startConnection(multiplePredictionString)
    }
    
    func requestStopPredictionData(stopTag:String, onRoute routeTag:String, withAgency agencyTag:String, closure:(predictions: [String : [TransitPrediction]], messages:[String]) -> Void) {
        currentRequestType = .StopPredictions
        
        stopPredictionsClosure = closure
        
        startConnection(stopPredictionsURL + agencyTag + routeURLSegment + routeTag + stopURLSegment + stopTag)
    }
    
    /**
    This is the method that all other request methods call in order to create the URL & start downloading data via an NSURLConnection
    
    - parameter requestURL: string of the url that is being requested
    */
    private func startConnection(requestURL:String) {
        xmlData = NSMutableData()
        let optionalURL:NSURL? = NSURL(string: requestURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        
        if let url = optionalURL as NSURL! {
            let urlRequest:NSURLRequest = NSURLRequest(URL: url)
            connection = NSURLConnection(request: urlRequest, delegate: self, startImmediately: true)
        } else {
            //TODO: Alert user via closure that something bad happened
        }
    }
    
    //MARK: NSURLConnectionDelegate
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        xmlString = NSString(data: xmlData, encoding: NSUTF8StringEncoding) as! String
        let xml = SWXMLHash.parse(xmlString)
        let parser = SwiftBusDataParser()
        
        switch currentRequestType {
        case .AllAgencies:
            parser.parseAllAgenciesData(xml, closure: allAgenciesClosure)
        case .AllRoutes:
            parser.parseAllRoutesData(xml, closure: allRoutesForAgencyClosure)
        case .RouteConfiguration:
            parser.parseRouteConfiguration(xml, closure: routeConfigClosure)
        case .VehicleLocations:
            parser.parseVehicleLocations(xml, closure: vehicleLocationsClosure)
        case .StationPredictions:
            parser.parseStationPredictions(xml, closure: stationPredictionsClosure)
        default:
            //Stop predictions
            parser.parseStopPredictions(xml, closure: stopPredictionsClosure)
        }
    }
    
    
    //MARK: NSURLConnectionDataDelegate
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
        xmlData.appendData(data)
    }
}