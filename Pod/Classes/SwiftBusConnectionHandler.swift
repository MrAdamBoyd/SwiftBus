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
    case noRequest = 0, allAgencies, allRoutes, routeConfiguration, stopPredictions, stationPredictions, vehicleLocations
}

class SwiftBusConnectionHandler: NSObject, NSURLConnectionDataDelegate {
    
    var currentRequestType:RequestType = .noRequest
    var connection:NSURLConnection?
    var xmlData = NSMutableData()
    var xmlString:String = ""
    var allAgenciesClosure:(([String : TransitAgency]) -> Void)!
    var allRoutesForAgencyClosure:(([String : TransitRoute]) -> Void)!
    var routeConfigClosure:((TransitRoute?) -> Void)!
    var stationPredictionsClosure:(([String : [String : [TransitPrediction]]]) -> Void)!
    var stopPredictionsClosure:(([String : [TransitPrediction]], [String]) -> Void)!
    var vehicleLocationsClosure:(([String : [TransitVehicle]]) -> Void)!
    
    //MARK: Requesting data
    
    func requestAllAgencies(_ closure: @escaping (_ agencies:[String : TransitAgency]) -> Void) {
        currentRequestType = .allAgencies
        
        allAgenciesClosure = closure
        
        startConnection(allAgenciesURL)
    }
    
    //Request data for all lines
    func requestAllRouteData(_ agencyTag: String, closure: @escaping (_ agencyRoutes:[String : TransitRoute]) -> Void) {
        currentRequestType = .allRoutes
        
        allRoutesForAgencyClosure = closure
        
        startConnection(allRoutesURL + agencyTag)
    }
    
    func requestRouteConfiguration(_ routeTag:String, fromAgency agencyTag:String, closure: @escaping (_ route: TransitRoute?) -> Void) {
        currentRequestType = .routeConfiguration
        
        routeConfigClosure = closure
        
        startConnection(routeConfigURL + agencyTag + routeURLSegment + routeTag)
    }
    
    func requestVehicleLocationData(onRoute routeTag:String, withAgency agencyTag:String, closure:@escaping (_ locations:[String : [TransitVehicle]]) -> Void) {
        currentRequestType = .vehicleLocations
        
        vehicleLocationsClosure = closure
        
        startConnection(vehicleLocationsURL + agencyTag + routeURLSegment + routeTag)
    }
    
    func requestStationPredictionData(_ stopTag: String, forRoutes routeTags:[String], withAgency agencyTag:String, closure: @escaping (_ predictions: [String : [String : [TransitPrediction]]]) -> Void) {
        currentRequestType = .stationPredictions
        
        stationPredictionsClosure = closure
        
        //Building the multi stop url
        var multiplePredictionString = multiplePredictionsURL + agencyTag
        for tag in routeTags {
            multiplePredictionString += multiStopURLSegment + tag + "|" + stopTag
        }
        
        startConnection(multiplePredictionString)
    }
    
    func requestStopPredictionData(_ stopTag:String, onRoute routeTag:String, withAgency agencyTag:String, closure:@escaping (_ predictions: [String : [TransitPrediction]], _ messages:[String]) -> Void) {
        currentRequestType = .stopPredictions
        
        stopPredictionsClosure = closure
        
        startConnection(stopPredictionsURL + agencyTag + routeURLSegment + routeTag + stopURLSegment + stopTag)
    }
    
    /**
    This is the method that all other request methods call in order to create the URL & start downloading data via an NSURLConnection
    
    - parameter requestURL: string of the url that is being requested
    */
    fileprivate func startConnection(_ requestURL:String) {
        xmlData = NSMutableData()
        let optionalURL:URL? = URL(string: requestURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        
        if let url = optionalURL as URL! {
            let urlRequest:URLRequest = URLRequest(url: url)
            connection = NSURLConnection(request: urlRequest, delegate: self, startImmediately: true)
        } else {
            //TODO: Alert user via closure that something bad happened
        }
    }
    
    //MARK: NSURLConnectionDelegate
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        xmlString = NSString(data: xmlData as Data, encoding: String.Encoding.utf8.rawValue) as! String
        let xml = SWXMLHash.parse(xmlString)
        let parser = SwiftBusDataParser()
        
        switch currentRequestType {
        case .allAgencies:
            parser.parseAllAgenciesData(xml, closure: allAgenciesClosure)
        case .allRoutes:
            parser.parseAllRoutesData(xml, closure: allRoutesForAgencyClosure)
        case .routeConfiguration:
            parser.parseRouteConfiguration(xml, closure: routeConfigClosure)
        case .vehicleLocations:
            parser.parseVehicleLocations(xml, closure: vehicleLocationsClosure)
        case .stationPredictions:
            parser.parseStationPredictions(xml, closure: stationPredictionsClosure)
        default:
            //Stop predictions
            parser.parseStopPredictions(xml, closure: stopPredictionsClosure)
        }
    }
    
    
    //MARK: NSURLConnectionDataDelegate
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        
        xmlData.append(data)
    }
}
