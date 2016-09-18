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

//A transit stop is a single stop which is tied to a single route
open class TransitStop:NSObject, NSCoding {
    
    open var routeTitle:String = ""
    open var routeTag:String = ""
    open var stopTitle:String = ""
    open var stopTag:String = ""
    open var agencyTag:String = ""
    open var direction:String = ""
    open var lat:Double = 0
    open var lon:Double = 0
    open var predictions:[String : [TransitPrediction]] = [:] //[direction : [prediction]]
    open var messages:[String] = []
    
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
    open func getPredictionsAndMessages(_ closure:@escaping (_ success:Bool, _ predictions:[String : [TransitPrediction]], _ messages:[String]) -> Void) {
        if agencyTag != "" {
            let connectionHandler = SwiftBusConnectionHandler()
            connectionHandler.requestStopPredictionData(self.stopTag, onRoute: self.routeTag, withAgency: self.agencyTag, closure: {(predictions:[String : [TransitPrediction]], messages:[String]) -> Void in
                
                self.predictions = predictions
                self.messages = messages
                
                //Call closure with success, predictions, and message
                closure(true, predictions, messages)
                
            })
        } else {
            //Stop doesn't exist
            closure(false, [:], [])
        }
    }
    
    /**
    Returns a list of all the predictions from the different directions in order
    
    - returns: In order list of all predictions from all different directions
    */
    open func combinedPredictions() -> [TransitPrediction] {
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
    
    public required init?(coder aDecoder: NSCoder) {
        routeTitle = aDecoder.decodeObject(forKey: routeTitleEncoderString) as! String
        routeTag = aDecoder.decodeObject(forKey: routeTagEncoderString) as! String
        stopTitle = aDecoder.decodeObject(forKey: stopTitleEncoderString) as! String
        stopTag = aDecoder.decodeObject(forKey: stopTagEncoderString) as! String
        agencyTag = aDecoder.decodeObject(forKey: agencyTagEncoderString) as! String
        direction = aDecoder.decodeObject(forKey: directionEncoderString) as! String
        lat = aDecoder.decodeDouble(forKey: latEncoderString)
        lon = aDecoder.decodeDouble(forKey: lonEncoderString)
        predictions = aDecoder.decodeObject(forKey: predictionsEncoderString) as! [String : [TransitPrediction]]
        messages = aDecoder.decodeObject(forKey: messagesEncoderString) as! [String]
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(routeTitle, forKey: routeTitleEncoderString)
        aCoder.encode(routeTag, forKey: routeTagEncoderString)
        aCoder.encode(stopTitle, forKey: stopTitleEncoderString)
        aCoder.encode(stopTag, forKey: stopTagEncoderString)
        aCoder.encode(agencyTag, forKey: agencyTagEncoderString)
        aCoder.encode(direction, forKey: directionEncoderString)
        aCoder.encode(lat, forKey: latEncoderString)
        aCoder.encode(lon, forKey: lonEncoderString)
        aCoder.encode(predictions, forKey: predictionsEncoderString)
        aCoder.encode(messages, forKey: messagesEncoderString)
    }
}
