//
//  TransitStop.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation

private let kRouteTitleEncoderString = "kRouteTitleEncoder"
private let kRouteTagEncoderString = "kRouteTagEncoder"
private let kStopTitleEncoderString = "kStopTitleEncoder"
private let kStopTagEncoderString = "kStopTagEncoder"
private let kAgencyTagEncoderString = "kAgencyTagEncoder"
private let kDirectionEncoderString = "kDirectionEncoder"
private let kLatEncoderString = "kLatEncoder"
private let kLonEncoderString = "kLonEncoder"
private let kPredictionsEncoderString = "kPredictionsEncoder"
private let kMessagesEncoderString = "kMessagesEncoder"

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
    
    - parameter finishedLoading: Code that is called after the call has been downloaded and parsed
        - parameter success:     Whether or not the call was a success
        - parameter predictions: The predictions, in all directions, for this stop
        - parameter messages:    The messages for this stop
    */
    public func getPredictionsAndMessages(finishedLoading:(success:Bool, predictions:[String : [TransitPrediction]], messages:[String]) -> Void) {
        if agencyTag != "" {
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestStopPredictionData(self.stopTag, onRoute: self.routeTag, withAgency: self.agencyTag, closure: {(predictions:[String : [TransitPrediction]], messages:[String]) -> Void in
                
                self.predictions = predictions
                self.messages = messages
                
                //Call closure with success, predictions, and message
                finishedLoading(success: true, predictions: predictions, messages: messages)
                
            })
        } else {
            //Stop doesn't exist
            finishedLoading(success: false, predictions: [:], messages: [])
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
        listOfPredictions.sort {
            return $0.predictionInSeconds < $1.predictionInSeconds
        }
        
        return listOfPredictions
    }
    
    //MARK: NSCoding
    
    public required init(coder aDecoder: NSCoder) {
        routeTitle = aDecoder.decodeObjectForKey(kRouteTitleEncoderString) as! String
        routeTag = aDecoder.decodeObjectForKey(kRouteTagEncoderString) as! String
        stopTitle = aDecoder.decodeObjectForKey(kStopTitleEncoderString) as! String
        stopTag = aDecoder.decodeObjectForKey(kStopTagEncoderString) as! String
        agencyTag = aDecoder.decodeObjectForKey(kAgencyTagEncoderString) as! String
        direction = aDecoder.decodeObjectForKey(kDirectionEncoderString) as! String
        lat = aDecoder.decodeDoubleForKey(kLatEncoderString)
        lon = aDecoder.decodeDoubleForKey(kLonEncoderString)
        predictions = aDecoder.decodeObjectForKey(kPredictionsEncoderString) as! [String : [TransitPrediction]]
        messages = aDecoder.decodeObjectForKey(kMessagesEncoderString) as! [String]
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(routeTitle, forKey: kRouteTitleEncoderString)
        aCoder.encodeObject(routeTag, forKey: kRouteTagEncoderString)
        aCoder.encodeObject(stopTitle, forKey: kStopTitleEncoderString)
        aCoder.encodeObject(stopTag, forKey: kStopTagEncoderString)
        aCoder.encodeObject(agencyTag, forKey: kAgencyTagEncoderString)
        aCoder.encodeObject(direction, forKey: kDirectionEncoderString)
        aCoder.encodeDouble(lat, forKey: kLatEncoderString)
        aCoder.encodeDouble(lon, forKey: kLonEncoderString)
        aCoder.encodeObject(predictions, forKey: kPredictionsEncoderString)
        aCoder.encodeObject(messages, forKey: kMessagesEncoderString)
    }
}