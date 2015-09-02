//
//  TransitStop.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 com.adam. All rights reserved.
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
class TransitStop:NSObject, NSCoding {
    var routeTitle:String = ""
    var routeTag:String = ""
    var stopTitle:String = ""
    var stopTag:String = ""
    var agencyTag:String = ""
    var direction:String = ""
    var lat:Double = 0
    var lon:Double = 0
    var predictions:[String : [TransitPrediction]] = [:]
    var messages:[String] = []
    
    //Init without predictions or direction
    init(routeTitle:String, routeTag:String, stopTitle:String, stopTag:String) {
        self.routeTitle = routeTitle
        self.routeTag = routeTag
        self.stopTitle = stopTitle
        self.stopTag = stopTag
    }
    
    /**
    Gets the predictions and messages for the current stop and calls the closure with the predictions and messages as a parameter. If the agency tag hasn't been loaded, it will call the closure with an empty dictionary.
    
    :param: closure Code that is called after the call has been downloaded and parsed
    */
    func getPredictionsAndMessages(closure:((predictions:[String : [TransitPrediction]], messages:[String]) -> Void)?) {
        if agencyTag != "" {
            let connectionHandler = ConnectionHandler()
            connectionHandler.requestStopPredictionData(self.stopTag, onRoute: self.routeTag, withAgency: self.agencyTag, closure: {(predictions:[String : [TransitPrediction]], messages:[String]) -> Void in
                
                self.predictions = predictions
                self.messages = messages
                
                //Call closure with predictions
                if let innerClosure = closure as (([String : [TransitPrediction]], [String]) -> Void)! {
                    innerClosure(predictions, messages)
                }
                
            })
        } else {
            //Call closure with nil
            if let innerClosure = closure as (([String : [TransitPrediction]], [String]) -> Void)! {
                innerClosure([:], [])
            }
        }
    }
    
    /**
    Returns a list of all the predictions from the different directions in order
    
    :returns: In order list of all predictions from all different directions
    */
    func combinedPredictions() -> [TransitPrediction] {
        var listOfPredictions:[TransitPrediction] = []
        
        for predictionDirection in predictions.values.array {
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
    
    required init(coder aDecoder: NSCoder) {
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
    
    func encodeWithCoder(aCoder: NSCoder) {
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