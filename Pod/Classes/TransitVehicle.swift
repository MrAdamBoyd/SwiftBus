//
//  TransitVehicle.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 Adam Boyd. All rights reserved.
//

import Foundation

private let vehicleIdEncoderString = "kVehicleIdEncoder"
private let directionTagEncoderString = "kDirectionTagEncoder"
private let latEncoderString = "kLatEncoder"
private let lonEncoderString = "kLonEncoder"
private let secondsSinceReportEncoderString = "kSecondsSinceReportEncoder"
private let leadingVehicleIdEncoderString = "kKeadingVehicleIdEncoder"
private let headingEncoderString = "kHeadingEncoder"
private let speedKmHEncoderString = "kSpeedKmHEncoder"

public class TransitVehicle:NSObject, NSCoding {
    
    public var vehicleId:Int = 0
    public var directionTag:String = ""
    public var lat:Double = 0
    public var lon:Double = 0
    public var secondsSinceReport:Int = 0
    public var leadingVehicleId:Int = 0
    public var heading:Int = 0
    public var speedKmH:Int = 0
    
    //Basic init
    public override init() { super.init() }
    
    //Init with proper things as Ints and Doubles
    public init(vehicleId:Int, directionTag:String, lat:Double, lon:Double, secondsSinceReport:Int, heading:Int, speedKmH:Int) {
        self.vehicleId = vehicleId
        self.directionTag = directionTag
        self.lat = lat
        self.lon = lon
        self.secondsSinceReport = secondsSinceReport
        self.heading = heading
        self.speedKmH = speedKmH
    }
    
    //Init with everything as string, convert in init
    public init(vehicleID:String, directionTag:String, lat:String, lon:String, secondsSinceReport:String, heading:String, speedKmH:String) {
        self.vehicleId = Int(vehicleID)!
        self.directionTag = directionTag
        self.lat = (lat as NSString).doubleValue
        self.lon = (lon as NSString).doubleValue
        self.secondsSinceReport = Int(secondsSinceReport)!
        self.heading = Int(heading)!
        self.speedKmH = Int(speedKmH)!
    }
    
    //MARK : NSCoding
    
    public required init(coder aDecoder: NSCoder) {
        vehicleId = aDecoder.decodeObjectForKey(vehicleIdEncoderString) as! Int
        directionTag = aDecoder.decodeObjectForKey(directionTagEncoderString) as! String
        lat = aDecoder.decodeDoubleForKey(latEncoderString)
        lon = aDecoder.decodeDoubleForKey(lonEncoderString)
        secondsSinceReport = aDecoder.decodeObjectForKey(secondsSinceReportEncoderString) as! Int
        leadingVehicleId = aDecoder.decodeObjectForKey(leadingVehicleIdEncoderString) as! Int
        heading = aDecoder.decodeObjectForKey(headingEncoderString) as! Int
        speedKmH = aDecoder.decodeObjectForKey(speedKmHEncoderString) as! Int
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(vehicleId, forKey: vehicleIdEncoderString)
        aCoder.encodeObject(directionTag, forKey: directionTagEncoderString)
        aCoder.encodeDouble(lat, forKey: latEncoderString)
        aCoder.encodeDouble(lon, forKey: lonEncoderString)
        aCoder.encodeObject(secondsSinceReport, forKey: secondsSinceReportEncoderString)
        aCoder.encodeObject(leadingVehicleId, forKey: leadingVehicleIdEncoderString)
        aCoder.encodeObject(heading, forKey: headingEncoderString)
        aCoder.encodeObject(speedKmH, forKey: speedKmHEncoderString)
    }
}