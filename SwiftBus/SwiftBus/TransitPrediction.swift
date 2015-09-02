//
//  TransitPrediction.swift
//  SwiftBus
//
//  Created by Adam on 2015-09-01.
//  Copyright (c) 2015 com.adam. All rights reserved.
//

import Foundation

class TransitPrediction: NSObject, NSCoding {
    
    var numberOfVehicles:Int = 0
    var predictionInMinutes:Int = 0
    var predictionInSeconds:Int = 0
    var vehicleTag:Int = 0
    
    //MARK : NSCoding
    required init(coder aDecoder: NSCoder) {
    
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
    }
    
}