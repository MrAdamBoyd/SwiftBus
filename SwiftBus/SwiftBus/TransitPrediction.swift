//
//  TransitPrediction.swift
//  SwiftBus
//
//  Created by Adam on 2015-09-01.
//  Copyright (c) 2015 com.adam. All rights reserved.
//

import Foundation

private let kNumberOfVehiclesEncoderString = "kNumberOfVehiclesEncoder"
private let kPredictionInMinutesEncoderString = "kPredictionInMinutesEncoder"
private let kPredictionInSecondsEncoderString = "kPredictionInSecondsEncoder"
private let kVehicleTagEncoderString = "kVehicleTagEncoder"

class TransitPrediction: NSObject, NSCoding {
    
    var numberOfVehicles:Int = 0
    var predictionInMinutes:Int = 0
    var predictionInSeconds:Int = 0
    var vehicleTag:Int = 0
    
    //Basic init
    override init() { super.init() }
    
    //Init with all parameters
    init(numberOfVehicles:Int, predictionInMinutes:Int, predictionInSeconds:Int, vehicleTag:Int) {
        self.numberOfVehicles = numberOfVehicles
        self.predictionInMinutes = predictionInMinutes
        self.predictionInSeconds = predictionInSeconds
        self.vehicleTag = vehicleTag
    }
    
    //MARK : NSCoding
    required init(coder aDecoder: NSCoder) {
        numberOfVehicles = aDecoder.decodeObjectForKey(kNumberOfVehiclesEncoderString) as! Int
        predictionInMinutes = aDecoder.decodeObjectForKey(kPredictionInMinutesEncoderString) as! Int
        predictionInSeconds = aDecoder.decodeObjectForKey(kPredictionInSecondsEncoderString) as! Int
        vehicleTag = aDecoder.decodeObjectForKey(kVehicleTagEncoderString) as! Int
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(numberOfVehicles, forKey: kNumberOfVehiclesEncoderString)
        aCoder.encodeObject(predictionInMinutes, forKey: kPredictionInMinutesEncoderString)
        aCoder.encodeObject(predictionInSeconds, forKey: kPredictionInSecondsEncoderString)
        aCoder.encodeObject(vehicleTag, forKey: kVehicleTagEncoderString)
    }
    
}