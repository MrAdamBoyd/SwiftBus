//
//  TransitAgency.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2015 com.adam. All rights reserved.
//

import Foundation

private let kAgencyTagEncoderString = "kAgencyTagEncoder"
private let kAgencyTitleEncoderString = "kAgencyTitleEncoder"
private let kAgencyRegionEncoderString = "kAgencyRegionEncoder"

class TransitAgency: NSObject, NSCoding {
    
    var agencyTag:String = ""
    var agencyTitle:String = ""
    var agencyRegion:String = ""
    
    //Convenvience
    override init() { }
    
    init(agencyTag:String, agencyTitle:String, agencyRegion:String) {
        self.agencyTag = agencyTag
        self.agencyTitle = agencyTitle
        self.agencyRegion = agencyRegion
    }

    //MARK : NSCoding
    
    required init(coder aDecoder: NSCoder) {
        agencyTag = aDecoder.decodeObjectForKey(kAgencyTagEncoderString) as! String
        agencyTitle = aDecoder.decodeObjectForKey(kAgencyTitleEncoderString) as! String
        agencyRegion = aDecoder.decodeObjectForKey(kAgencyRegionEncoderString) as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(agencyTag, forKey: kAgencyTagEncoderString)
        aCoder.encodeObject(agencyTitle, forKey: kAgencyTitleEncoderString)
        aCoder.encodeObject(agencyRegion, forKey: kAgencyRegionEncoderString)
    }
}