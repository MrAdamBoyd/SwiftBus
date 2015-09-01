//
//  TransitVehicle.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 com.adam. All rights reserved.
//

import Foundation

private let kVehicleIdEncoderString = "kVehicleIdEncoder"
private let kLatEncoderString = "kLatEncoder"
private let kLonEncoderString = "kLonEncoder"
private let kSecondsSinceReportEncoderString = "kSecondsSinceReportEncoder"
private let kLeadingVehicleIdEncoderString = "kKeadingVehicleIdEncoder"
private let kHeadingEncoderString = "kHeadingEncoder"
private let kSpeedKmHEncoderString = "kSpeedKmHEncoder"

class TransitVehicle:NSObject, NSCoding {
    
    var vehicleId:Int = 0
    var lat:Double = 0
    var lon:Double = 0
    var secondsSinceReport:Int = 0
    var leadingVehicleId:Int = 0
    var heading:Int = 0
    var speedKmH:Int = 0
    
    //MARK : NSCoding
    
    required init(coder aDecoder: NSCoder) {
        vehicleId = aDecoder.decodeObjectForKey(kVehicleIdEncoderString) as! Int
        lat = aDecoder.decodeDoubleForKey(kLatEncoderString)
        lon = aDecoder.decodeDoubleForKey(kLonEncoderString)
        secondsSinceReport = aDecoder.decodeObjectForKey(kSecondsSinceReportEncoderString) as! Int
        leadingVehicleId = aDecoder.decodeObjectForKey(kLeadingVehicleIdEncoderString) as! Int
        heading = aDecoder.decodeObjectForKey(kHeadingEncoderString) as! Int
        speedKmH = aDecoder.decodeObjectForKey(kSpeedKmHEncoderString) as! Int
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(vehicleId, forKey: kVehicleIdEncoderString)
        aCoder.encodeDouble(lat, forKey: kLatEncoderString)
        aCoder.encodeDouble(lon, forKey: kLonEncoderString)
        aCoder.encodeObject(secondsSinceReport, forKey: kSecondsSinceReportEncoderString)
        aCoder.encodeObject(leadingVehicleId, forKey: kLeadingVehicleIdEncoderString)
        aCoder.encodeObject(heading, forKey: kHeadingEncoderString)
        aCoder.encodeObject(speedKmH, forKey: kSpeedKmHEncoderString)
    }
}