//
//  TransitPrediction.swift
//  SwiftBus
//
//  Created by Adam on 2015-09-01.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation

private let numberOfVehiclesEncoderString = "kNumberOfVehiclesEncoder"
private let predictionInMinutesEncoderString = "kPredictionInMinutesEncoder"
private let predictionInSecondsEncoderString = "kPredictionInSecondsEncoder"
private let vehicleTagEncoderString = "kVehicleTagEncoder"

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
    
    //Init with all parameters except number of vehicles
    public init(predictionInMinutes:Int, predictionInSeconds:Int, vehicleTag:Int) {
        self.predictionInMinutes = predictionInMinutes
        self.predictionInSeconds = predictionInSeconds
        self.vehicleTag = vehicleTag
    }
    
    //MARK : NSCoding
    public required init(coder aDecoder: NSCoder) {
        numberOfVehicles = aDecoder.decodeObjectForKey(numberOfVehiclesEncoderString) as! Int
        predictionInMinutes = aDecoder.decodeObjectForKey(predictionInMinutesEncoderString) as! Int
        predictionInSeconds = aDecoder.decodeObjectForKey(predictionInSecondsEncoderString) as! Int
        vehicleTag = aDecoder.decodeObjectForKey(vehicleTagEncoderString) as! Int
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(numberOfVehicles, forKey: numberOfVehiclesEncoderString)
        aCoder.encodeObject(predictionInMinutes, forKey: predictionInMinutesEncoderString)
        aCoder.encodeObject(predictionInSeconds, forKey: predictionInSecondsEncoderString)
        aCoder.encodeObject(vehicleTag, forKey: vehicleTagEncoderString)
    }
    
}