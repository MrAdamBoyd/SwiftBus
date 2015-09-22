//
//  TransitStop.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation

private let routeTitleEncoderString = "kRouteTitleEncoder"
private let routeTagEncoderString = "kRouteTagEncoder"
private let stopTitleEncoderString = "kStopTitleEncoder"
private let stopTagEncoderString = "kStopTagEncoder"
private let agencyTagEncoderString = "kAgencyTagEncoder"
private let directionEncoderString = "kDirectionEncoder"
private let latEncoderString = "kLatEncoder"
private let lonEncoderString = "kLonEncoder"
private let predictionsEncoderString = "kPredictionsEncoder"
private let messagesEncoderString = "kMessagesEncoder"

//Stored stop identifiers to get the data from
public class TransitStop:NSObject, NSCoding {
    
    public var routeTitle:String = ""
    public var routeTag:String = ""
    public var stopTitle:String = ""
    public var stopTag:String = ""
    public var agencyTag:String = ""
    public var direction:String = ""
    public var lat:Double = 0
    public var lon:Double = 0
    public var predictions:[String : [TransitPrediction]] = [:]
    public var messages:[String] = []
    
    //Init without predictions or direction
    public init(routeTitle:String, routeTag:String, stopTitle:String, stopTag:String) {
        self.routeTitle = routeTitle
        self.routeTag = routeTag
        self.stopTitle = stopTitle
        self.stopTag = stopTag
    }
    
    /**
    Gets the predictions and messages for the current stop and calls the closure with the predictions and messages as a parameter. If the agency tag hasn't been loaded, it will call the closure with an empty dictionary.
    
    - parameter closure:    Code that is called after the call has been downloaded and parsed
        - parameter success:     Whether or not the call was a success
        - parameter predictions: The predictions, in all directions, for this stop
        - parameter messages:    The messages for this stop
    */
    public func getPredictionsAndMessages(closure:(success:Bool, predictions:[String : [TransitPrediction]], messages:[String]) -> Void) {
        if agencyTag != "" {
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestStopPredictionData(self.stopTag, onRoute: self.routeTag, withAgency: self.agencyTag, closure: {(predictions:[String : [TransitPrediction]], messages:[String]) -> Void in
                
                self.predictions = predictions
                self.messages = messages
                
                //Call closure with success, predictions, and message
                closure(success: true, predictions: predictions, messages: messages)
                
            })
        } else {
            //Stop doesn't exist
            closure(success: false, predictions: [:], messages: [])
        }
    }
    
    /**
    Returns a list of all the predictions from the different directions in order
    
    - returns: In order list of all predictions from all different directions
    */
    public func combinedPredictions() -> [TransitPrediction] {
        var listOfPredictions:[TransitPrediction] = []
        
        for predictionDirection in predictions.values {
            //Going through each direction
            listOfPredictions += predictionDirection
        }
        
        //Sorting the list
        listOfPredictions.sortInPlace {
            return $0.predictionInSeconds < $1.predictionInSeconds
        }
        
        return listOfPredictions
    }
    
    //MARK: NSCoding
    
    public required init?(coder aDecoder: NSCoder) {
        routeTitle = aDecoder.decodeObjectForKey(routeTitleEncoderString) as! String
        routeTag = aDecoder.decodeObjectForKey(routeTagEncoderString) as! String
        stopTitle = aDecoder.decodeObjectForKey(stopTitleEncoderString) as! String
        stopTag = aDecoder.decodeObjectForKey(stopTagEncoderString) as! String
        agencyTag = aDecoder.decodeObjectForKey(agencyTagEncoderString) as! String
        direction = aDecoder.decodeObjectForKey(directionEncoderString) as! String
        lat = aDecoder.decodeDoubleForKey(latEncoderString)
        lon = aDecoder.decodeDoubleForKey(lonEncoderString)
        predictions = aDecoder.decodeObjectForKey(predictionsEncoderString) as! [String : [TransitPrediction]]
        messages = aDecoder.decodeObjectForKey(messagesEncoderString) as! [String]
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(routeTitle, forKey: routeTitleEncoderString)
        aCoder.encodeObject(routeTag, forKey: routeTagEncoderString)
        aCoder.encodeObject(stopTitle, forKey: stopTitleEncoderString)
        aCoder.encodeObject(stopTag, forKey: stopTagEncoderString)
        aCoder.encodeObject(agencyTag, forKey: agencyTagEncoderString)
        aCoder.encodeObject(direction, forKey: directionEncoderString)
        aCoder.encodeDouble(lat, forKey: latEncoderString)
        aCoder.encodeDouble(lon, forKey: lonEncoderString)
        aCoder.encodeObject(predictions, forKey: predictionsEncoderString)
        aCoder.encodeObject(messages, forKey: messagesEncoderString)
    }
}