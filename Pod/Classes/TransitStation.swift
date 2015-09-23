//
//  TransitStation.swift
//  Pods
//
//  Created by Adam on 2015-09-21.
//
//

import Foundation

private let routesAtStationEncoderString = "routesAtStationEncoder"
private let stopTitleEncoderString = "stopTitleEncoder"
private let stopTagEncoderString = "stopTagEncoder"
private let agencyTagEncoderString = "agencyTagEncoder"
private let latEncoderString = "latEncoder"
private let lonEncoderString = "lonEncoder"
private let predictionsEncoderString = "predictionsEncoder"
private let messagesEncoderString = "messagesEncoder"

//A tranit station is a single station id tied to multiple transit routes
public class TransitStation:NSObject, NSCoding {
    public var routesAtStation:[TransitRoute] = []
    public var stopTitle:String = ""
    public var stopTag:String = ""
    public var agencyTag:String = ""
    public var lat:Double = 0
    public var lon:Double = 0
    public var predictions:[String : [String : [TransitPrediction]]] = [:] //[routeTag : [direction : prediction]]
    public var messages:[String] = []
    
    //Basic init
    public override init() { super.init() }
    
    /**
    Initializes the object with everything needed to get the route config
    
    - parameter stopTitle:          title of the stop
    - parameter stopTag:            4 digit tag of the stop
    - parameter routesAtStation:    array of routes that go to the station
    
    - returns: None
    */
    public init(stopTitle:String, stopTag:String, routesAtStation:[TransitRoute]) {
        self.stopTitle = stopTitle
        self.stopTag = stopTag
        self.routesAtStation = routesAtStation
    }
    
    /**
    Returns a list of all the predictions from the different directions in order
    
    - returns: In order list of all predictions from all different directions
    */
    public func combinedPredictions() -> [TransitPrediction] {
        var listOfPredictions:[TransitPrediction] = []
        //TODO: Update for how station is structured
        for line in predictions.values {
            //Going through each line
            for predictionDirection in line.values {
                //Going through each direction
                listOfPredictions += predictionDirection
            }
        }
        
        //Sorting the list
        listOfPredictions.sortInPlace {
            return $0.predictionInSeconds < $1.predictionInSeconds
        }
        
        return listOfPredictions
    }
    
    //MARK: NSCoding
    
    public required init?(coder aDecoder: NSCoder) {
        routesAtStation = aDecoder.decodeObjectForKey(routesAtStationEncoderString) as! [TransitRoute]
        stopTitle = aDecoder.decodeObjectForKey(stopTitleEncoderString) as! String
        stopTag = aDecoder.decodeObjectForKey(stopTagEncoderString) as! String
        agencyTag = aDecoder.decodeObjectForKey(agencyTagEncoderString) as! String
        lat = aDecoder.decodeDoubleForKey(latEncoderString)
        lon = aDecoder.decodeDoubleForKey(lonEncoderString)
        predictions = aDecoder.decodeObjectForKey(predictionsEncoderString) as! [String : [String : [TransitPrediction]]]
        messages = aDecoder.decodeObjectForKey(messagesEncoderString) as! [String]
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(routesAtStation, forKey: routesAtStationEncoderString)
        aCoder.encodeObject(stopTitle, forKey: stopTitleEncoderString)
        aCoder.encodeObject(stopTag, forKey: stopTagEncoderString)
        aCoder.encodeObject(agencyTag, forKey: agencyTagEncoderString)
        aCoder.encodeDouble(lat, forKey: latEncoderString)
        aCoder.encodeDouble(lon, forKey: lonEncoderString)
        aCoder.encodeObject(predictions, forKey: predictionsEncoderString)
        aCoder.encodeObject(messages, forKey: messagesEncoderString)
    }
}