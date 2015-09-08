//
//  TransitPrediction.swift
//  SwiftBus
//
//  Created by Adam on 2015-09-01.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation

private let kNumberOfVehiclesEncoderString = "kNumberOfVehiclesEncoder"
private let kPredictionInMinutesEncoderString = "kPredictionInMinutesEncoder"
private let kPredictionInSecondsEncoderString = "kPredictionInSecondsEncoder"
private let kVehicleTagEncoderString = "kVehicleTagEncoder"

public class TransitPrediction: NSObject, NSCoding {
    
    public var numberOfVehicles:Int = 0
    public var predictionInMinutes:Int = 0
    public var predictionInSeconds:Int = 0
    public var vehicleTag:Int = 0
    
    //Basic init
    public override init() { super.init() }
    
    //Init with only # of minutes
    public init(predictionInMinutes:Int) {
        self.predictionInMinutes = predictionInMinutes
        self.predictionInSeconds = self.predictionInMinutes * 60
    }
    
    //Init with all parameters
    public init(numberOfVehicles:Int, predictionInMinutes:Int, predictionInSeconds:Int, vehicleTag:Int) {
        self.numberOfVehicles = numberOfVehicles
        self.predictionInMinutes = predictionInMinutes
        self.predictionInSeconds = predictionInSeconds
        self.vehicleTag = vehicleTag
    }
    
    //MARK : NSCoding
    public required init(coder aDecoder: NSCoder) {
        numberOfVehicles = aDecoder.decodeObjectForKey(kNumberOfVehiclesEncoderString) as! Int
        predictionInMinutes = aDecoder.decodeObjectForKey(kPredictionInMinutesEncoderString) as! Int
        predictionInSeconds = aDecoder.decodeObjectForKey(kPredictionInSecondsEncoderString) as! Int
        vehicleTag = aDecoder.decodeObjectForKey(kVehicleTagEncoderString) as! Int
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(numberOfVehicles, forKey: kNumberOfVehiclesEncoderString)
        aCoder.encodeObject(predictionInMinutes, forKey: kPredictionInMinutesEncoderString)
        aCoder.encodeObject(predictionInSeconds, forKey: kPredictionInSecondsEncoderString)
        aCoder.encodeObject(vehicleTag, forKey: kVehicleTagEncoderString)
    }
    
}